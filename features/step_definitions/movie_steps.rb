# Add a declarative step here for populating the DB with movies.

module MovieStepHelpers
  def values_from_list(list_argument, table_argument)
    entries = if table_argument
                if table_argument.respond_to?(:headers) && table_argument.headers&.any?
                  table_argument.hashes.flat_map(&:values)
                else
                  table_argument.raw.flatten
                end
              else
                list_argument.to_s.split(/\s*,\s*/)
              end

    entries.map { |entry| entry.to_s.strip }.reject(&:empty?)
  end

  def apply_checkbox_action(action, entries)
    entries.each do |entry|
      step %{I #{action} "#{entry}" checkbox}
    end
  end

  def negated?(token)
    token.to_s.strip == 'not'
  end

  def assert_movie_visibility(movie_titles, negate)
    movie_titles.each do |title|
      if negate
        step %{I should not see "#{title}"}
      else
        step %{I should see "#{title}"}
      end
    end
  end
end

World(MovieStepHelpers)

Given(/the following movies exist/) do |movies_table|
  movies_table.hashes.each do |movie|
    record = Movie.where(title: movie['title']).first_or_initialize
    record.update!(movie)
  end
end

Then(/(.*) seed movies should exist/) do |n_seeds|
  expect(Movie.count).to eq n_seeds.to_i
end

# Make sure that one string (regexp) occurs before or after another one
#   on the same page

Then(/^I should see "(.*)" before "(.*)"(?: in the movie list)?$/) do |first_title, second_title|
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

Given(/^I check the following ratings: (.*)$/) do |rating_list|
  apply_checkbox_action('check', values_from_list(rating_list, nil))
end

Given(/^I check the following ratings:$/) do |ratings_table|
  apply_checkbox_action('check', values_from_list(nil, ratings_table))
end

Given(/^I uncheck the following ratings: (.*)$/) do |rating_list|
  apply_checkbox_action('uncheck', values_from_list(rating_list, nil))
end

Given(/^I uncheck the following ratings:$/) do |ratings_table|
  apply_checkbox_action('uncheck', values_from_list(nil, ratings_table))
end

Then(/^I should (not )?see the following movies: (.*)$/) do |negate, movie_list|
  assert_movie_visibility(values_from_list(movie_list, nil), negated?(negate))
end

Then(/^I should (not )?see the following movies:$/) do |negate, movies_table|
  assert_movie_visibility(values_from_list(nil, movies_table), negated?(negate))
end

Then(/^I should see all the movies$/) do
  # Make sure that all the movies in the app are visible in the table
  within('#movies') do
    table_rows = all('table tbody tr').to_a
    table_rows = all('table tr').to_a.drop(1) if table_rows.empty? && has_css?('table tr')

    row_count = if table_rows.any?
                  table_rows.length
                else
                  all(:css, 'div[id^="movie_"]').size
                end

    expect(row_count).to eq(Movie.count)
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
