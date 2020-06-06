# Author: Gamaliel Amaudruz
# Version: 3.0 - 6.6.2020
# Roadmap: html; rails?
# bug: to_s isn't called automatically for  

require 'csv'

NBR_BEST = 10
SHOW_ONLY_ABOVE = 7

#For multiple sort criterias, see  Enumerable#sort_by

class Movie
  include Comparable
  attr_reader :name, :year, :rating, :average, :director, :url

  def initialize(name, year, rating, average, director, url)
    @name = name
    @year = year.to_i
    @rating = rating.to_i
    @average = average.to_f
    @director = director
    @url = url
  end

  def <=>(other)
    [@rating, @average] <=> [other.rating, other.average] #if same rating, the imdb average decides
  end

  def to_s
    @name
  end
end

class Year
  include Comparable
  attr_reader :movies

  def initialize(name, movies)
    @name = name
    if movies.is_a?(Array)
      @movies = movies
    elsif movies.is_a?(Movie)
      @movies = [movies]
    end
  end

  def assign_movies(movies)
    @movies = movies
  end

  def add_movie(movie)
    @movies ||= []
    @movies << movie
  end

  def average_rating
    @movies.inject(0) { |sum, movie| sum + movie.rating }.to_f / @movies.length.to_f
  end

  def nbr_movies
    @movies.length
  end

  def to_s
    "#{@name}"
  end

  def <=>(other)
    @name <=> other&.name
  end
end

years = {}

# IMDB format 2020
# Const,Your Rating,Date Rated,Title,URL,Title Type,IMDb Rating,Runtime (mins),Year,Genres,Num Votes,Release Date,Directors
# tt1000774,4,2008-11-12,Sex and the City,https://www.imdb.com/title/tt1000774/,movie,5.6,145,2008,"Comedy, Drama, Romance",113269,2008-05-12,Michael Patrick King

CSV.foreach("ratings.csv", {headers: true, encoding: "ISO-8859-1:UTF-8"}) do |row|

  movie = Movie.new(
      row.field('Title'),
      row.field('Year'),
      row.field('Your Rating'),
      row.field('IMDb Rating'),
      row.field('Directors'),
      row.field('URL')
  )

  if (years.has_key?(movie.year)) then
    years[movie.year].add_movie(movie)
  else
    years[movie.year] = Year.new(movie.year, movie)
  end
end #file read

#File write
result = File.new("results.txt", modestring = "w")

result.puts "\nStatistics based on #{years.values.inject(0) { |sum, year| sum + year.nbr_movies }} movie votes."

result.puts "\n@@@@@ Average per year @@@@@"
best_year = [0, 0] #[year, avg]
MIN_VOTES_BEST_YEAR = 10
AVG_ROUND_FT = '%.2f'

#Average rating per year
years.keys.sort.each do |year| #nested array with key, value
  year = years[year]

  # result.puts year
  result.puts "Year #{year.to_s} has #{year.nbr_movies} movies, your average is: #{AVG_ROUND_FT % year.average_rating}"
  puts "Year #{year.to_s} has #{year.nbr_movies} movies, your average is: #{AVG_ROUND_FT % year.average_rating}"
end

best_year = years.values.select { |year| year.nbr_movies >= MIN_VOTES_BEST_YEAR }.sort_by { |year| year.average_rating }.last
result.puts "\nYour favourite year: #{best_year.to_s} with average: #{AVG_ROUND_FT % best_year.average_rating} (minimum #{MIN_VOTES_BEST_YEAR} votes to qualify)."

result.puts "\n\n@@@@@@ Best Of by year @@@@@@@"
#top movies by year
years.keys.sort.each do |year|
  year = years[year]
  best_of = year.movies.sort.last(NBR_BEST).reverse!
  it = 1
  result.puts "\n#========= Best of #{year.to_s} (#{year.nbr_movies} movies, your average=#{AVG_ROUND_FT % year.average_rating}) ============================"
  best_of.select { |m| m.rating >= SHOW_ONLY_ABOVE }.each do |movie|
    result.puts "#{it}. #{movie.name} (#{movie.director}): #{movie.rating}    (#{movie.url})"
    it += 1
  end
end

result.puts "\n\n\n\n@@@@@@ Best Of by decade @@@@@@"
#top movie by decade
decade_movies = []
first_year = years.keys.sort.first
last_year = years.keys.sort.last
decade_start = first_year
# puts "This year: #{Time.new.year}"

puts "Range is #{first_year}-#{last_year}"

(first_year..last_year).each do |year|
  decade_movies = decade_movies + years[year].movies unless years[year] == nil

  if (year % 10 == 0 || year == last_year) then
    # time to compute the decade bestof
    result.puts "\n#========= Best of decade #{decade_start}-#{year}  (#{decade_movies.length} movies, your average=#{ AVG_ROUND_FT % (decade_movies.inject(0) { |sum, m| sum + m.rating }.to_f / decade_movies.length.to_f)}) ============================" #xxx puts nbr of movie and my average and imdb average

    decade_movies = decade_movies.sort.last(NBR_BEST).reverse #truncating the array
    it = 1
    decade_movies.select { |m| m.rating >= SHOW_ONLY_ABOVE }.each do |movie|
      result.puts "#{it}. #{movie.name} (#{movie.director}): #{movie.rating}    (#{movie.url})"
      it += 1
    end
    # reset for the next decade
    decade_movies = Array.new
    decade_start = year + 1
    # else
    # decade_movies = decade_movies + years[year]
  end
end

result.close