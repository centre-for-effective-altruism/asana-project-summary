const knex = require('knex')({
  client: 'pg',
  connection: 'postgres://postgres@postgres/postgres',
  searchPath: ['knex', 'public'],
})
const asana = require('asana').Client.create().useAccessToken(process.env.ASANA_ACCESS_TOKEN);
const fs = require('mz/fs')

const EXCLUDED_SECTIONS_GIDS = process.env.ASANA_EXCLUDED_SECTIONS_GIDS.split(',')
console.log('ESGIDS', EXCLUDED_SECTIONS_GIDS)
const TASK_FIELDS = 'name,custom_fields,created_at,completed_at,memberships.section.name,resource_subtype'

async function fetchFullAsanaCollection(collection) {
  let result = []
  while (collection) {
    result = result.concat(collection.data)
    collection = await collection.nextPage()
  }
  return result
}

async function getAsanaTasks() {
  const tasksCollection = await asana.projects.tasks(
    process.env.ASANA_PROJECT_GID,
    {
      limit: 100,
      opt_fields: TASK_FIELDS
    }
  )
  return fetchFullAsanaCollection(tasksCollection)
}

function isInExcludedSecion(task) {
  return task.memberships.some(membership =>
    membership.section && EXCLUDED_SECTIONS_GIDS.includes(membership.section.gid)
  )
}

function getValue(task) {
  for (field of task.custom_fields) {
    if (field.gid === process.env.ASANA_VALUE_FIELD_GID) {
      return field.number_value
    }
  }
  return null
}

function filterTasks (tasks) {
  return tasks.filter(task => {
    if (task.resource_subtype === 'section') return false
    if (isInExcludedSecion()) return false
    if (!getValue(task)) return false
    return true
  })
}

async function upsertDbTasks (tasks) {
  const tasksForDb = tasks.map(task => {
    task.value = getValue(task)
    // TODO; partial completion (next pr)
    task.partial_completion = 0
    delete task.custom_fields
    delete task.id
    delete task.memberships
    delete task.resource_subtype
    return task
  })
  const buf = await fs.readFile('gettasks.sql')
  const sql = buf.toString().replace('{{tasks}}', JSON.stringify(tasksForDb))
  const knexthing = knex.raw(sql)
  console.log('knexthing', knexthing)
  await knexthing
}

async function getTasks () {
  const tasks = await getAsanaTasks()
  const tasksOfInterest = filterTasks(tasks)
  await upsertDbTasks(tasksOfInterest)
}

async function run () {
  try {
    await getTasks()
  } finally {
    await knex.destroy()
  }
}

run()
