# Buildkiq

AWS CodeBuild container launcher

- Buildkiq enables you to run UnitTest in a distributed manner.
- And many more

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'buildkiq'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install buildkiq

## Configuration

You need to configure [AWS SDK](https://github.com/aws/aws-sdk-ruby) credentials

Create configuration file (~/.aws/credentials) or require environments `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` and `AWS_REGION`

## Usage

### :rocket: run by CLI

#### Example: create build 2 containers

```sh
$ buildkiq run_builds -p your_project_name \
  -c "ruby -v" \
  -e "CI=true,NODE_TOTAL=2" \
  -b "NODE_INDEX=1" "NODE_INDEX=2"
```

##### build:1

```
% export CI=true && export NODE_TOTAL=2
% export NODE_INDEX=1
% ruby -v
```

##### build:2

```
% export CI=true && export NODE_TOTAL=2
% export NODE_INDEX=2
% ruby -v
```

#### CLI Parameters

| name                | alias | desc                                      | required | type   |
| ------------------- | ----- | ----------------------------------------- | -------- | ------ |
| project             | -p    | AWS CodeBuild project name                | **Yes**  | String |
| builds_environments | -b    | builds environments (csv)                 | **Yes**  | Array  |
| environments        | -e    | common environments (csv)                 | No       | String |
| source_version      | -s    | git commit hash or github pullrequest     | No       | String |
| command             | -c    | override buildspec.yml with shell command | No       | String |

### :rocket: run by ruby

#### Example: create build 2 containers

```ruby
jobs = Buildkiq.run(project:              'your_project_name',
                    build_cmd:            'ruby -v', # override buildspec.yml
                    default_environments: [{name: 'CI', value: 'true'}, {name: 'NODE_TOTAL', value: '2'}],
                    jobs: [
                            {environments: [{name: 'NODE_INDEX', value: '1'}]},
                            {environments: [{name: 'NODE_INDEX', value: '2'}]},
                          ])

puts jobs.size      # 2
puts jobs[0].status # IN_PROGRESS
jobs[0].wait_for_job
puts jobs[0].status # SUCCEEDED
puts jobs[0].build.class # Aws::CodeBuild::Types::Build

# Download artifacts file from S3
# json_text = jobs[0].artifact.find_by('path/to/spec.json')
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bluerabbit/buildkiq.

