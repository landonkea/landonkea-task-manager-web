# Feature Ideas

Concrete feature ideas for this task manager, based on what's actually here today:
plain tasks with a name, a done flag, an optional single category, name/category
search, and a single-user login. No due dates, no priority, no tags beyond one
category string, no attachments, no sorting beyond insertion order.

Recurring task generation (scheduled templates that spawn tasks) is already in
progress on PR #2 and isn't repeated here. Everything below is something else.

## Task data model

1. **Due dates.** A `due_on` column on `Task`, an index for sorting, and an overdue
   badge on `_task.html.erb` next to the existing status badge. The single highest-
   value addition on this list - almost nobody manages a task list without dates.

2. **Priority levels.** An enum column (`low` / `medium` / `high`, or just an integer)
   with a scope like `Task.high_priority` mirroring the existing `Task.completed` /
   `Task.pending` pattern in `app/models/task.rb`. Sort the index by priority first.

3. **Notes/description field.** A `text` column beyond the 255-char `name`, shown on
   `show.html.erb` and editable in `_form.html.erb`. Right now there's nowhere to put
   detail like "call the plumber before 2pm, ask about the quote from March."

4. **Multiple tags instead of one category.** The current `category` column holds a
   single string. A join table (`tags` + `task_tags`) would let a task be both
   "work" and "urgent" at once, which the current schema can't express.

5. **Manual reordering.** Add a `position` integer and drag-and-drop reordering on
   the index page (Stimulus + a small `acts_as_list`-style scope). Right now the
   task order is just database insertion order, with no way to say "this one first."

6. **Soft delete / archive instead of hard delete.** `TasksController#destroy` calls
   `@task.destroy!`, which is permanent. An `archived_at` timestamp plus a default
   scope excluding archived tasks would let people undo an accidental delete.

## Views and interaction

7. **Bulk actions.** Checkboxes on the index page plus "mark selected done" / "delete
   selected" buttons. Useful the moment someone has more than a handful of tasks -
   right now every action is one task at a time.

8. **Calendar view.** Once due dates exist (#1), a month view - even a simple table
   grid with tasks listed under their due date - gives a completely different way to
   scan a week's workload than the current flat list.

9. **Keyboard shortcuts.** `j`/`k` to move between tasks, `x` to toggle done, `n` for
   a new task. A small Stimulus controller listening for keydown events on the index
   page; no new backend work needed at all.

10. **Undo toast after destructive actions.** After delete or "mark done," show a
    Turbo-rendered toast with a 5-second undo link instead of (or alongside) #6's
    archive column. Cheap to build, and it's the difference between "deleted" feeling
    safe versus scary.

11. **Dark mode toggle.** `app/assets/stylesheets/application.css` currently ships one
    palette. A `prefers-color-scheme` media query plus a manual override stored in a
    cookie (no new DB column needed) covers most people's actual ask here.

## Collaboration

12. **Multiple users, not just one login.** `app/models/user.rb` and the `resource
    :session` route already support real accounts (`has_secure_password`,
    `Session` model) - there's just no signup path and no `user_id` on `Task`. Adding
    both turns this from a personal list into something a household or small team
    could actually use.

13. **Shared/assigned task lists.** Once tasks belong to a user (#12), a `List` model
    that tasks belong to, with a join table for "which users can see this list,"
    supports the classic "honey-do list" or small-team-project use case.

14. **Activity log.** A lightweight `TaskEvent` model recording who changed what and
    when (created, marked done, edited). Genuinely useful the first time two people
    share a list and someone asks "wait, who marked this done?"

## Notifications

15. **Due-date reminder emails.** `ApplicationMailer` already exists but nothing uses
    it yet. A daily `SendDueReminderJob` (Solid Queue is already wired up) that emails
    tasks due today or overdue would close that gap with almost no new infrastructure.

16. **Browser push via the existing service worker.** `app/views/pwa/service-worker.js`
    is already in place as a stub. Wiring up the Web Push API for "task due in 1 hour"
    notifications would make real use of the PWA setup that currently does nothing.

## API and integrations

17. **Full-text search across notes, not just name/category.** Once #3 adds a notes
    field, the existing `Task.search` scope's `LIKE` query needs to cover it too, or
    it'll silently miss the field most likely to contain the thing someone's searching
    for. Worth calling out now so it isn't a "why doesn't this find my task" bug later.

18. **CSV export/import.** A `GET /tasks.csv` action alongside the existing
    `format.json` responses in `TasksController`, and a matching import form. Lets
    someone move their list in or out without touching the database directly, and
    it's a natural fit next to the JSON API that's already there.

19. **Webhook on task completion.** A `WebhookEndpoint` model plus an `after_update`
    callback (or better, an Active Job so a slow webhook can't stall the request) that
    POSTs task data somewhere on completion. Opens the door to Zapier-style integrations
    without building an OAuth API from scratch.

20. **Simple stats page.** A `/stats` route showing tasks completed this week, average
    time-to-done, and a per-category breakdown. All derivable from data that already
    exists (`created_at`, `updated_at`, `done`, `category`) - no schema changes needed,
    just a controller action and some `group`/`count` queries.
