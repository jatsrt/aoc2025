# Load support files
Code.require_file("support/day_case.ex", __DIR__)

ExUnit.start()

# Configure tags:
# - Run only example tests by default (fast feedback)
# - Use --include solution to run full puzzle tests
ExUnit.configure(exclude: [:solution])
