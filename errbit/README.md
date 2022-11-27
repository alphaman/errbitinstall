# errbit

tests:
 - Git:
  -- installed
 - MongoDB:
  -- started
  -- enabled
  -- listening on port
  -- installed 
 - Erbbit
   -- user created
   -- listening on port
   -- started
   -- enabled
 - Ruby:
  -- check ruby version 2.7.6

 attributes located in attributes->default

run ```kitchen test``` for tests

run ```kitchen create && kitchen converge``` to boot up and bootstrap a running instance
