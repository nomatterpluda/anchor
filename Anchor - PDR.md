**Anchor**

**Product Requirements Document** 

**App Name:** Anchor  
**Platform:** iOS \- Native

**1\. Overview**

Anchor is a native iOS productivity app centred on a daily time-blocking workflow. It integrates a single-day calendar view with a to-do list organised by projects. Users can assign tasks to time blocks, customize their schedule, and optionally receive reminders—all within a sleek, low-maintenance interface.

**Target Users & Value Proposition**

Anchor offers a different way to tackle task management, providing a hybrid solution for professionals and individuals who juggle multiple projects that require dedicated time allocation. Anchor allows users to define how they want to split their day and assign tasks to each time block so that their attention is anchored to that specific time block.

**2\. App Architecture \- Dual Layer Interface**

The app features a dual-layer interface with the calendar view as the primary layer and the to-do list underneath.

**Layer Structure:**

* Primary: Daily calendar view (24-hour time blocks)  
* Secondary: Project-based to-do list panel beneath

**Resizable Calendar Layer**

The calendar functions as a resizable overlay (like a reversed Apple sheet) that can be adjusted to four positions. Users drag the bottom part of the sheet (containing a calendar bar) to resize, allowing dynamic balance between time planning and task management in one fluid interface.

When the calendar's drag handle is out of comfortable thumb reach, users can perform a **vertical swipe on the left or right edges** of the to-do section to resize the calendar layer. This ensures smooth one-handed operation regardless of the current layer position.

**3\. Core User Experience**

**3.1 Home View \- Daily Calendar View**

* Vertical, scrollable 24-hour calendar view (00:00 \- 24:00; customisable range in settings) with a calendar bar at the bottom showing the selected day, month, and year.   
* A red dot appears next to the day name when viewing today's date.  
* Swipe left/right on the calendar view to change days (+/- 1 day).  
* Tap on date on the calendar bar to reveal a calendar picker for quick navigation.

**3.2 Time Blocks**

* Time blocks appear as draggable/resizable rectangles within the Daily Calendar View (just like native calendar events).  
* Tap and hold to create a block; drag top/bottom edges to resize  
  * **Default duration:** 1 hour (customisable in settings).  
  * **Overlap behaviour:** When dragging a time block, it automatically snaps to the nearest available time slot without overlapping existing blocks.  
  * **Limitations:** Blocks cannot span multiple days.  
  * **Day swap:** Time blocks can be moved from one day to another  
* Assign a name, icon and color (manually or by project association, see below).  
* New/empty time blocks have default grey color, default icon and title. All can be overwritten manually by the user. If a task is added to an empty time block, the time block takes the colour of the project. If tasks from multiple projects are added to the same time block, the color remains the default one. Manually selected colours always override project association colours.  
* Time blocks displayed in calendar view display content based on available vertical space:  
  * Small time block: only shows the name and number of tasks  
  * Medium time block: shows name and underneath number of tasks  
  * Large time blocks: shows name and tasks  
* Optional settings:  
  * Notifications (start and/or end) of time block.  
* Tapping a block opens detail sheet/modal with:  
  * Block details.  
  * Task (checklist).  
  * Edit block info.  
  * Add 5 minutes to the block.  
  * Delete the block.

**3.3 To-Do List Panel**

* Accessed by swiping Daily Calendar View.  
* Horizontally scrollable project selector at bottom of view.  
  * **"All" Project:** Default project containing all tasks across projects. Always appears last in horizontal scroll. Cannot be deleted or renamed. Provides unified view of all tasks regardless of project assignment.  
  * Swipe left past start to create new project inline.  
  * Each project has:  
    * Name  
    * Icon  
    * Color  
  * Tap active project to reveal three-button menu:  
    * Rename  
    * Delete  
    * Reorder project (opens modal with vertical drag list)  
* Two vertical sections within each project:  
  * To-Do: Active tasks  
  * Done: Completed tasks (limited to 3/4 recent tasks plus button view more, which opens a native sheet with all completed tasks)

**3.4 Task Structure**

* Each task includes:  
  * Name  
  * Completion checkbox at left (ideally with rive completion animation/haptic/sound, ref Superlist)  
  * (Optional) date, priority  
* Added via "+" inline entry in to-do section  
* **Priority sorting:** Tasks with priority automatically appear at the bottom of the task list (always visible), automatically sorted.  
* Task Assignment Behavior:  
  * Tasks can be assigned (dragged) to multiple time blocks  
  * Visual indicator appears on todo list when task is assigned and shows relation only the closest/next scheduled time block.  
  * When a time block ends, the indicator on the relative todo in the todo list is replaced with the closest time block (if available).  
  * If no future time blocks assigned to a task, no time indicator is shown  
  * The task remains in the project "To-Do" list regardless of time block assignment.  
* **Swipe right** on task: group into task stack (see below)  
* **Swipe left** on task: delete task  
* **Tap name** to enter edit mode

**3.5 Task Stacks**

Task stacks are a list of pinned stacks that appear above the project row and can be made of tasks from multiple projects. This allows for stacks to be grouped and dragged to a time block all at the same time.

**4\. Task Editing Interface**

* Keyboard opens immediately for name editing  
* Quick-access buttons above keyboard:  
  * Due Date (opens calendar picker)  
  * Priority (low, medium, high)  
  * Change project (move task to a different project)  
* Notification toggle appears only if due date is set  
* Tapping away dismisses keyboard and saves task automatically

**5\. Settings/Profile Sheet**

Triggered via tap on project icon \-\> settings (Apple-style bottom sheet)

**5.1 Trial banner (if user is on trial)**

**5.2 Preferences**

* Time format: 12h / 24h  
* First day of week: Sunday / Monday  
* Day starts/ends at: time if user wants to limit the 24h view  
* Default time block duration: 15min / 30min / 1h / 2h  
* Toggle sounds  
* Toggle haptics  
* Icon selection (nice to have)  
* Appearance: Light / Dark / Auto (future implementation \- tbd)

**5.3 Support**

* Send feedback (opens mail or form)  
* FAQ / Help (opens Browser or sheet)  
* Redo onboarding  
* App version display

**6\. Monetisation Strategy: Trial \+ Subscription Model**

**Duration: 1 month** (30 days) with full feature access:

* All features unlocked from day one  
* Apple subscription required for trial start  
* Clear trial status indicator in app settings  
* Gentle reminders at, 3 days  
* Grace period: 3 days past trial end with read-only access

**7\. Onboarding Flow**

1. Welcome \+ Value Prop \- "Plan your day, anchor your focus”  
2. Create First Time Block \- Interactive tutorial (tap/hold, drag to resize)  
3. Introduce Projects \- Show "All" project, create custom project, add task  
4. Assign First Task \- Drag task to time block or use block detail view

Each step should be skippable for experienced users.

**8\. Technical Stack**

* **Frontend:** Swift \+ SwiftUI  
* **Local Storage:** Swift Data (tbd)  
* **Performance:** App should be fluid, smooth and hyper-polished. Should feel native with an extra layer of humanity made of selected haptic feedbacks and sounds  
* **Offline Functionality:** The app should work completely offline  
* **Notifications:** UNUserNotificationCenter (local only)  
* **Design Tools:** Figma (UI), Rive (for animations), Play (prototypes)

**9\. Future Features (Post v1)**

* Habit tracking module  
* Calendar integration (Apple Calendar)  
* Analytics (time spent on tasks)  
* iPad layout  
* Widgets  
* Smart task time/date recognition (local)  
* Smart suggestions for rescheduling uncompleted tasks  
* Repeating tasks and time blocks

**10\. Edge Cases & Error Handling**

* **Empty states:** No tasks, no projects, no time blocks  
* **Notification permissions:** Graceful handling when denied  
* **Offline functionality:** All core features available without internet

