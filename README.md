# Coffeefinder

A Ruby CLI app for finding local coffee shops and other places that sell coffee

![coffeefinder demo](./coffeefinder.gif)

## Installation

First, you will need to get an API key from Yelp. 

Create an account at https://www.yelp.com, then go https://www.yelp.com/developers/faq and follow the steps outlined under the heading 'How can I get started using the Yelp Fusion API?'. 

Once those are done, go to 'Manage app' and join the developer beta to gain access to the Yelp GraphQL API. Once that's done, copy the long string at the top of the page under the heading 'API Key'. 

Save that key somewhere safe using a text editor, then in your terminal type `export YELP_API_KEY=your_api_key_goes_here`.

Next, using your terminal in the coffeefinder project directory root, run the command `./bin/setup`, followed by `bundle exec rake install`.

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
## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ghemsley/coffeefinder.
