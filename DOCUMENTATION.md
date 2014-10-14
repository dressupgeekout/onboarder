# ONBOARDER Documentation

**Christian Koch** -- ck AT norse-corp DOT com

Last updated: Tue Oct 14 14:57:13 PDT 2014

-----

The Onboarder tool is a convenient front-end to [Redmine][]. It allows a
Human Resource department to keep track of everything that needs to be done
when a new hire is needs to be onboarded.

-----

## Getting ready

### Requirements from Redmine

Your Redmine installation must have _all_ of the following things set up in
order for Onboarder to work properly:

- at least one regular Redmine user
- at least one administrative Redmine user
- Redmine must have API authentication enabled
- a Redmine project under which all onboarding tickets will be filed
- a default tracker
- a default issue status


### Requirements from Onboarder

Once you have set up everything inside Redmine, you can begin using
Onboarder. However, you won't be able to use Onboarder to actually file
tickets inside Redmine until you set up the following:

- At least one Department must be created.
- At least one Onboarder role must be created.
- At least one task needs to be added to the task map.

-----

## Theory of Operation/Workflow Example

Suppose Onboarder is being used at Acme Company. Here is how everything ties
together:

- The _task map_ defines
  - (1) which tasks need to be taken care of for _any_ possible onboarding
    procedure, and
  - (2) which employees (who already work at Acme Co.) are responsible for
    those tasks.
  - For example, Acme Co.'s IT Person is responsible for setting up the new
    hire's email account, while Acme Co.'s Chief Accountant is responsible
    for preparing tax forms.

- Every new hire will belong to exactly one _Department_. Departments are
  specified with the _task table_, which denotes _which_ of the tasks even
  apply for a new hire for a given department.
  - For example, incoming developers might require access to a Git
    repository, but incoming salespeople do not.

-----

## Notes

There's a notion of a "role" but this has nothing to do with Redmine's
notion of a "role."


[Redmine]: http://redmine.org
