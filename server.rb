require 'sinatra'
require 'pg'
require 'pry'
require_relative 'class_actor'
require_relative 'class_character'
require_relative 'class_movie'

DBNAME = 'movies'

def db_connection
  begin
    connection = PG.connect(dbname: DBNAME)
    yield(connection)
  ensure
    connection.close
  end
end

get '/' do
  redirect '/actors'
end

get '/actors' do
  actors = Actor.all
  erb :'actors/actors', locals: {actors: actors}
end

get '/actors/:id' do
  characters = Character.get_by_actor_id(params["id"])
  erb :'actors/actor', locals: {characters: characters}
end

get '/movies' do
  movies = Movie.all_by_title
  erb :'movies/movies', locals: {movies: movies}
end

get '/movies/:id' do
  characters = Character.get_by_movie_id(params["id"])
  movie = Movie.get_by_movie_id(params["id"])
  erb :'movies/movie', locals: {characters: characters, movie: movie}
end

# binding.pry
