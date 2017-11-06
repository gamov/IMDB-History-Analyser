IMDB-History-Analyser
=====================

Use this ruby script to parse your [IMDB](http://imdb.com/) rating history. It does the following:

- Show the number of movies and average rating for each year
- Determine your favorite year
- Create Best Of's by year
- Create Besf Of's by decade

Movies will have their associated rating, the director(s)' name and a URL to the IMDB website.

ratings.csv is an example input and results.txt is the associated output.

Usage
-----
Run the script on a computer with Ruby installed (version >= 2.3):

    > ruby movie_ratings_analyzer.rb

You must have the file 'ratings.csv' that you downloaded from IMDB in the same directory as the script.
'results.txt' is the output of the script.

There are two parameters you can tinker with (just change their value in the script and save it):

- SHOW_ONLY_ABOVE: Determines the lowest rating a movie can have to appear in the Best Of's
- NBR_BEST: Max number of movies appearing in Best Of's


Enjoy,
Gam.


PS: Based on IMDB export format as of 15.6.12

To Do
-----
- add by Director (careful multiple (comma separated); weighted average chart)
The formula for calculating the Top Rated 250 Titles gives a true Bayesian estimate:

weighted rating (WR) = (v ÷ (v+m)) × R + (m ÷ (v+m)) × C
Where:

R = average for the movie (mean) = (Rating)
v = number of votes for the movie = (votes)
m = minimum votes required to be listed in the Top 250 (currently 25000)
C = the mean vote across the whole report (currently 7.0)
For the Top 250, only votes from regular voters are considered.
from: http://www.imdb.com/chart/top?sort=ir,desc

- remove irrelevant entries based on 'Title type' like 'TV Episode' Using a filter array (to include/ exclude) ['Feature Film', '']
