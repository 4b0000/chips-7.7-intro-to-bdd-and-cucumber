# Add a declarative step here for populating the DB with movies.

Given(/the following movies exist/) do |movies_table|
  Movie.destroy_all
  movies_table.hashes.each do |movie|
    Movie.create!(movie)
  end
end

Then(/(.*) seed movies should exist/) do |n_seeds|
  expect(Movie.count).to eq n_seeds.to_i
end

# Make sure that one string (regexp) occurs before or after another one
#   on the same page

Then(/^I should see "(.*)" before "(.*)"$/) do |first_title, second_title|
  movies_section = find('#movies')
  page_text = movies_section.text
  first_index = page_text.index(first_title)
  second_index = page_text.index(second_title)

  expect(first_index).not_to be_nil, "Expected to find '#{first_title}' in movie list"
  expect(second_index).not_to be_nil, "Expected to find '#{second_title}' in movie list"
  expect(first_index).to be < second_index,
                        "Expected '#{first_title}' to appear before '#{second_title}'"
end


# Make it easier to express checking or unchecking several boxes at once
#  "When I check only the following ratings: PG, G, R"

When(/I check the following ratings: (.*)/) do |rating_list|
  # HINT: use String#split to split up the rating_list, then
  #   iterate over the ratings and reuse the "When I check..." or
  #   "When I uncheck..." steps in lines 89-95 of web_steps.rb
  rating_list.split(/\s*,\s*/).each do |rating|
    step %{I check "#{rating}" checkbox}
  end
end

Then(/^I should (not )?see the following movies: (.*)$/) do |no, movie_list|
  # Take a look at web_steps.rb Then /^(?:|I )should see "([^"]*)"$/
  movie_list.split(/\s*,\s*/).each do |movie|
    if no
      step %{I should not see "#{movie}"}
    else
      step %{I should see "#{movie}"}
    end
  end
end

Then(/^I should see all the movies$/) do
  # Make sure that all the movies in the app are visible in the table
  within('#movies') do
    expect(page).to have_css('div[id^="movie_"]', count: Movie.count)
  end
end

### Utility Steps Just for this assignment.

Then(/^debug$/) do
  # Use this to write "Then debug" in your scenario to open a console.
  require "byebug"
  byebug
  1 # intentionally force debugger context in this method
end

Then(/^debug javascript$/) do
  # Use this to write "Then debug" in your scenario to open a JS console
  page.driver.debugger
  1
end

Then(/complete the rest of of this scenario/) do
  # This shows you what a basic cucumber scenario looks like.
  # You should leave this block inside movie_steps, but replace
  # the line in your scenarios with the appropriate steps.
  raise "Remove this step from your .feature files"
end
