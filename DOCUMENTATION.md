# ONBOARDER Documentation

Christian Koch -- ck@norse-corp.com

-----

The Onboarder tool is a convenient front-end to [Redmine][]

-----

## Getting ready

### Requirements from Redmine

Your Redmine installation must have _all_ of the following things set up in
order for Onboarder to work properly:

  - at least one Redmine user
  - Redmine must have API authentication enabled
  - a Redmine project under which onboarding tickets will be filed
  - a default tracker
  - a default issue status


### Requirements from Onboarder

Once you have set up everything inside Redmine, you can begin using
Onboarder. However, you won't be able to use Onboarder to actually file
tickets inside Redmine until you set up the following:

  - At least one Onboarder role must be created.
  - At least one task needs to be added to the task map.

-----

## Database schema

Onboarder does not use a traditional object-relational mapper (ORM) and
instead uses Plain Old Ruby Objects (POROs) and PStore.

    DB.transaction {
      DB[:config] = {
        :redmine_api_key      => String,
        :redmine_uri          => String,
        :default_redmine_proj => String,
        :hiring_manager       => String,
        :footer               => String,
      }

      DB[:roles] = {
        "Role 1" => String (user identifier),
        "Role 2" => String (user identifier),
        ...,
      }

      DB[:tasks] = [
        {
          :subject  => String,
          :assignee => String,
        }
      ]
    }


-----

## Notes

There's a notion of a "role" but this has nothing to do with Redmine's
notion of a "role."


[Redmine]: http://redmine.org
