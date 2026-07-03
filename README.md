# Dovolenkomat

Simple vacation request tracker for small companies. Employees submit a
vacation request with a date range, HR reviews it, and finally the head of
the company approves or rejects it. HR and the head can also submit their
own requests without needing peer review at their own level, and the head
can set a cap on how many people can be on vacation at the same time.

Three roles:
- **employee** – submits requests, sees their own vacations on a calendar
- **hr** – approves/rejects pending requests
- **head** – has final approval, can override HR, manages user accounts and
  the max-concurrent-vacationers setting

Ruby/Rails version: see `.ruby-version` (Ruby 3.4.8, Rails 8.1).

## Requirements

- MySQL running locally (uses the `mysql2` gem, see `config/database.yml`)

## Setup

```
cp .env.example .env   # adjust if your local MySQL needs different credentials
bundle install
rails db:create db:migrate db:seed
bin/dev
```

`db/seeds.rb` creates a head, two HR users, a few employees, and a handful
of vacation requests in different states so there's something to look at
right away. Login credentials are printed at the end of the seed run
(all passwords are `password123`).
