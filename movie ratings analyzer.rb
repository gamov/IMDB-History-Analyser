# Author: Gamaliel Amaudruz
# Version: 2.0 - 15.6.12
# Roadmap: html; rails?
# bug: to_s isn't called automatically for  


nbr_best = 15
show_only_above=8 #xxxx

#xxx add path_url in movie
# imdb_base_url='http://www.imdb.com'
# imdb_base_url='http://www.imdb.com/title'


#For multiple sort criterias, see  Enumerable#sort_by

### REGEX ####

movie_line_regex = /"\d"/

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
    @movies.inject(0){|sum, movie| sum + movie.rating}.to_f / @movies.length.to_f
  end
  
  def nbr_movies
    @movies.length
  end
  
  def to_s
    @name
  end
  
  def <=>(other) 
    @name <=> other.name 
  end
end

# counter = 1
# movie_counter = 0
# movies = []
years = {}

# test = "baboo"
# puts "#{test.delete "a","o"}"

# IMDB format 15.6.12
#"position","const","created","modified","description","Title","Title type","Directors","You rated","IMDb Rating","Runtime (mins)","Year","Genres","Num. Votes","Release Date (month/day/year)","URL"
# "1","tt1446714","Thu Jun 14 00:00:00 2012","","","Prometheus","Feature Film","Ridley Scott","3","7.7","124","2012","action, horror, sci_fi","59979","2012-05-30","http://www.imdb.com/title/tt1446714/"
i_imdb_id = 1
i_vote_created = 2
i_vote_modified = 3 #doesn't seem to be in use
i_title = 5
i_director = 7
i_my_rating = 8
i_imdb_rating = 9
i_year = 11
i_url = 15

#### main program, we analyze the file
File.open("ratings.csv", "r") do |infile|
  # File.open("My Movies_extract.html", "r") do |infile|
  # infile.each_line do |line|
  while (line = infile.gets)
    if line =~ movie_line_regex then
      # movie_counter += 1

      # Identifies data, cleans it up and put in array
      m_a = line.scan(/".*?"/).map{|it| it.gsub('"','')} #gsub('"','')

      # puts m_a[i_imdb_id]

      #we create our movie object
      movie =  Movie.new(m_a[i_title], m_a[i_year], m_a[i_my_rating], m_a[i_imdb_rating], m_a[i_director], m_a[i_url]);

      if (years.has_key?(movie.year)) then
        years[movie.year].add_movie(movie)
      else 
        years[movie.year] = Year.new(movie.year, movie)
      end
      # puts "-----"
      next
    end #movie processing
  end #file read

  #File write
  result = File.new("results.txt", modestring="w")

  result.puts "\nStatistics based on #{years.values.inject(0){|sum, year| sum + year.nbr_movies}} movie votes."

  result.puts "\n@@@@@ Average per year @@@@@"
  best_year = [0,0] #[year, avg]
  MIN_VOTES_BEST_YEAR = 10
  AVG_ROUND_FT = '%.2f'

  #Average rating per year
  years.keys.sort.each do |year| #nested array with key, value
    year = years[year]

    # result.puts year
    result.puts "Year #{year.to_s} has #{year.nbr_movies} movies, your average is: #{AVG_ROUND_FT % year.average_rating}"
    puts "Year #{year.to_s} has #{year.nbr_movies} movies, your average is: #{AVG_ROUND_FT % year.average_rating}"
  end
  
  best_year = years.values.select{|year| year.nbr_movies >= MIN_VOTES_BEST_YEAR}.sort_by{|year| year.average_rating}.last  
  result.puts "\nYour favorite year: #{best_year.to_s} with average: #{AVG_ROUND_FT % best_year.average_rating} (with minimum #{MIN_VOTES_BEST_YEAR} votes to qualify)."

  result.puts "\n\n@@@@@@ Best Of by year @@@@@@@"
  #top movies by year
  years.keys.sort.each do |year|
    year = years[year]
    best_of = year.movies.sort.last(nbr_best).reverse! 
    it = 1
    result.puts "\n#========= Best of #{year.to_s} (#{year.nbr_movies} movies, your average=#{AVG_ROUND_FT % year.average_rating}) ============================"
    best_of.each do |movie|
      result.puts "#{it}. #{movie.name}: #{movie.rating}   (#{movie.url})"      
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
    decade_movies = decade_movies + years[year].movies unless years[year]==nil

    if (year%10 == 0 || year == last_year) then
      # time to compute the decade bestof
      result.puts "\n#========= Best of decade #{decade_start}-#{year}  (#{decade_movies.length} movies, your average=#{ AVG_ROUND_FT % (decade_movies.inject(0){|sum, m| sum + m.rating }.to_f / decade_movies.length.to_f)}) ============================" #xxx puts nbr of movie and my average and imdb average

      decade_movies = decade_movies.sort.last(nbr_best).reverse #truncating the array
      it = 1
      decade_movies.each do |movie|
        result.puts  "#{it}. #{movie.name}: #{movie.rating}   (#{movie.url})"    
        it += 1
      end
      # reset for the next decade
      decade_movies = Array.new
      decade_start = year+1
      # else
      # decade_movies = decade_movies + years[year]
    end
  end

  result.close
end