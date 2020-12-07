# Coffeefinder

A Ruby CLI app for finding nearby coffee shops and other places that sell coffee

![coffeefinder demo](./coffeefinder.gif)

## Installation

First, you will need to get an API key from Yelp. 

Create an account at https://www.yelp.com, then go https://www.yelp.com/developers/faq and follow the steps outlined under the heading 'How can I get started using the Yelp Fusion API?'. 

Once those are done, go to 'Manage app' and join the developer beta to gain access to the Yelp GraphQL API. Once that's done, copy the long string at the top of the page under the heading 'API Key'. 

Save that key somewhere safe using a text editor, then in your terminal type `export YELP_API_KEY=your_api_key_goes_here`.

Clone this respitory (if you don't know how [there are some instructions here](https://docs.github.com/en/free-pro-team@latest/github/creating-cloning-and-archiving-repositories/cloning-a-repository)) and then `cd` into the directory created by the cloning process.

Next, in the coffeefinder project directory root, run the command `./bin/setup` to install dependencies, followed by `bundle exec rake install` to install the program as a gem.

Now you should be ready to run Coffeefinder!

## Usage

```
Usage: coffeefinder [options]

    -r, --radius MILES               How big of an area to search, in miles. Default: 0.5, max 10
    -s, --sort_by STRING             How to sort results. Acceptable values: 'distance', 'rating', 'review_count', 'best_match'. Default: 'best_match'
    -l, --limit INTEGER              How many results to show at once. Default: 10, max: 50
    -i, --ip IP_ADDRESS              IP address to use for geolocation lookup. Default: Your public IP
    -v, --version                    Display the program version
    -h, --help                       Display a helpful usage guide
```

Launching the program without options works too; it will use the default radius, sorting method, and results limit and will lookup your location using your public IP address.

Once launched, the program can search for and display coffee shops/other businesses that sell coffee. By default the program guesses your location using a geoIP lookup service, or you can search by address. You can also optionally save results to a favorites list for easy reference later. The favorites list will be saved in the file `~/.coffeefinder.json`. Deleting or clearing all your favorites will get rid of the file for you automatically.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ghemsley/coffeefinder.

## License

[MIT License](./LICENSE)
