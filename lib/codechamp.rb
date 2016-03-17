require "pry"
require "httparty"
require "json"
require "codechamp/version"

module Codechamp
  class App
    include HTTParty
    base_uri "https://api.github.com"

    def initialize(auth, org, repo)
      @headers = {
        "Authorization" => "token #{auth}",
        "User-Agent"    => "HTTParty"
      }
      @org = org
      @repo = repo
      @contributions = []
      @add_totals = []
      @delete_totals = []
      @commit_totals = []
    end

    def list_repo
      App.get("/repos/#{@org}/#{@repo}/stats/contributors", headers: @headers)
    end

    def get_usernames
      results = []
      set_contributions
      @contributions.each do |contributor|
        login = contributor["author"]["login"]
        results.push(login)
      end
      results
    end

    def set_contributions
      @contributions = list_repo
    end

    def get_weeks_data
      weeks_array = []
      set_contributions
      @contributions.each do |contribution|
        contributor = contribution["weeks"]
        weeks_array.push(contributor)
      end
      weeks_array
    end

    def set_totals
      get_weeks_data.each do |week|
        add = 0
        delete = 0
        changes = 0
        week.each do |sub_week|
          add += sub_week["a"]
          delete += sub_week["d"]
          changes += sub_week["c"]
        end
        @add_totals.push(add)
        @delete_totals.push(delete)
        @commit_totals.push(changes)
      end
    end

    def totals_array
      new_array = []
      count = 0
      set_totals
      get_usernames.each do |user|
        new_array[count] = [user, @add_totals[count], @delete_totals[count],
        @commit_totals[count]]
        count += 1
      end
      new_array
    end

    def sort_by_lines_added
      totals_array.sort_by {|a| a[1]}
    end

    def sort_by_lines_deleted
      totals_array.sort_by {|d| d[2]}
    end

    def sort_by_total_commits
      totals_array.sort_by {|c| c[3]}
    end

    def sort_by_lines_changed
      totals_array.sort_by {|h| h[1]-h[2]}
    end

    def spaces(word)
      word = word.to_s
      blank_space = " " * (18 - word.length)
      blank_space
    end

    def table
      table_array = []
      puts "
      enter 'a' for sort by additions
      enter 'd' for sort by deletions
      enter 'c' for sort by commits
      enter 'h' for sort by changes
      enter anything else for default"
      choice = gets.chomp.downcase
      case choice
      when "a"
        table_array = sort_by_lines_added
      when "d"
        table_array = sort_by_lines_deleted
      when "c"
        table_array = sort_by_total_commits
      when "h"
        table_array = sort_by_lines_changed
      else
        table_array = totals_array
      end
      puts "UserName          Additions         Deletions       Changes"
      table_array.each do |user|
        puts "#{user[0]}#{spaces(user[0])}#{user[1]}#{spaces(user[1])}#{user[2]}#{spaces(user[2])}#{user[3]}#{spaces(user[3])}"
      end
      nil
    end
  end
end

puts "Enter your authorization token:"
auth_token = gets.chomp
puts "Enter the owner/organization to get data about from Github:"
org = gets.chomp
puts "Enter the repo to get data about from Github:"
repo = gets.chomp
puts "Enter 'run.table' to get a formated table with sorting options"

run = Codechamp::App.new(auth_token, org, repo)
