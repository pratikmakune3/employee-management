### Learning resources for Elixir and Phoenix

If you're a complete newbie to elixir and phoenix, These resources could be a good start up and running.

1. [Elixir Tutorial](https://www.youtube.com/watch?v=-lgtb-YSUWE)
2. [Phoenix Tutorial](https://www.youtube.com/watch?v=9xaN44PNxps)
3. Official docs by elixir and phoenix

### 📑 1.Create an employee resource and implement default CRUD operations

1. Utilising the command - `mix phx.gen.json Employees Employee employees full_name:string job_title:string country_id:references:countries salary:decimal currency_id:references:currencies` it generated necessary schema, modules, functions and migration file. Migration file initially had 2 default indexs on coloumns - `country_id` and `currency_id`. Removed the default index on `currency_id` as our query pattern doesn't have that requirement. Created a new index on `job_title` as we have a query pattern to do salary calculations based on `job_title`.

2. The data model for the Employees table is updated to include FK references to `country_id` and `currency_id`, to ensure data integrity and consistency.

3. After running migration, DB is up with the above changes and is ready but phoenix application isn't aware of these DB changes and we need to explicitly make these schema changes by adding `belongs_to` in `Employee` and `has_many` in `Country` and `Currency`. Added `country_id` and `currency_id` in `Employee` changeset as required params in a request to take care of validations.

4. Fixed and updated the generated tests for Employee resource to accommodate associations with `country_id` and `currency_id`

5. Created `EmployeeSeeder` module in `seeds.exs` to seed employees, created parameterised `seedEmployees` function to take count as an input and generates as many Employee entity and seed in the DB.

### 🧮 2.Implement an endpoint to provide salary metrics about employees

1. get salary metrics filtered by country_code: `/employees/salary-metrics?country_code={country code}`
   decided to filter it by `country_code` as it's concise and easy for user to input

2. get salary metrics filtered by job_title: `/employees/salary-metrics?job_title={job title}`

3. Wrote tests for Employees model and controller

   > (Nice to have but not implemented - It's nice to handle if no filter params is provided then we compute salary metrics for all the users without any filtering...)

### Performance Optimisations/Considerations

1. **Implemented caching using Cachex 3.6 :**
   `salary-metrics` is good usecase for caching as it's computationally intesive task, read heavy and there are no frequent updates, so I decided to cache the response based on key as `country_code` and `job_title`. I kept ttl as 3600 seconds ~ 1 hour for both the endpoints. It's just a guess point with the assumption that we might not be having a lot of updates coming within 1 hour and we're ok to serve the stale data within that duration if we receive updates, but this decision should not be guess driven but should be data driven based on application metrics. With this thought, I looked up for a few options to implement simple caching solution, decided to give it a shot by using `Cachex 3.6` as it's a simple cache library using in-memory storage. I used `:fifo` as a evicition policy, no good reasoning behind using it, it's just a default and simple one but it's easily configurable to use other eviction policies - `LRU`, `LFU`, `random deletes`.

2. In calculating `salary-metrics`, fetched employees filtered by `country_code` and `job_title` and did `min`, `max` and `avg` calculations on the application side, just to keep it simple and making the application code independent of infrastructure concern i.e. Database concern here. But it has some performance trade-offs - it's not performant on network layer, as I'm passing all the matching employees from DB layer to application layer and then doing calculation in application layer. A possible performance optimisation could be to write raw SQL query like - `SELECT min(salary), avg(salary), max(salary) FROM employees where country_id = (SELECT id FROM countries where code=?)`
   With this approach DB would've done computation and passed as much amount of bytes over the network but again, that utilises DB's compute resource. So like every decision in tech, each has it's own pros and cons. As a newbie to elixir and phoenix, I decided to go with simple to implement approach skipping the network optimisation.
