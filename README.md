rendering_caching
=========================

Rendering caching like traditional action caching but with the functionality of fragment caching.

Installation
------------

Add this line to your application's Gemfile:

```ruby
gem 'rendering_caching'
```

And then execute:

    $ bundle

Usage
-----

```ruby
class ListsController < ApplicationController
  before_action :authenticate

  caches_rendering :index, :show
end
```


Contributing
------------

1. Fork it.
2. Create your feature branch (`git checkout -b my-new-feature`).
3. Commit your changes (`git commit -am 'Add some feature'`).
4. Push to the branch (`git push origin my-new-feature`).
5. Create a new Pull Request.

Code Status
-----------

* [![Build Status](https://github.com/tkawa/rendering_caching/actions/workflows/ci.yml/badge.svg)](https://github.com/tkawa/rendering_caching/actions/workflows/ci.yml)
