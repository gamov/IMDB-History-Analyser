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
Run the script on a computer with Ruby installed (version >= 1.9.3):

    > ruby movie_ratings_analyzer.rb

You must have the file 'ratings.csv that you downloaded from IMDB in the same directory as the script.
'results.txt' is the output of the script.

There are two parameters you can tinker with (just change their value in the script and save it):

- SHOW_ONLY_ABOVE: Determines the lowest rating a movie can have to appear in the Best Of's
- NBR_BEST: Max number of movies appearing in Best Of's


Enjoy,
Gam.


PS: Based on IMDB export format as of 15.6.12

To Do
-----
- remove irrelevant entries based on 'Title type' like 'TV Episode'