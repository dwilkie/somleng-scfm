# somleng-scfm-avf

[![Build Status](https://travis-ci.org/dwilkie/somleng-scfm-avf.svg?branch=master)](https://travis-ci.org/dwilkie/somleng-scfm-avf)
[![Test Coverage](https://api.codeclimate.com/v1/badges/919a7e91bfbfa6e34c9c/test_coverage)](https://codeclimate.com/github/dwilkie/somleng-scfm-avf/test_coverage)
[![Maintainability](https://api.codeclimate.com/v1/badges/919a7e91bfbfa6e34c9c/maintainability)](https://codeclimate.com/github/dwilkie/somleng-scfm-avf/maintainability)

Somleng Simple Call Flow Manager (Somleng SCFM) for African Voices Foundation (AVF) is a fork of [Somleng SCFM](https://github.com/somleng/somleng-scfm) adapted for the [African Voices Foundation](http://www.africasvoices.org/). Please see [Somleng SCFM](https://github.com/somleng/somleng-scfm) for more general information about Somleng Simple Call Flow Manager.

## Architecture

<pre>
    +----------------+
    |   Contacts     |
    +----------------+
 +--| * id           |---+
 |  | * msisdn       |   |
 |  | * metadata     |   |
 |  |                |   |
 |  +----------------+   |
 |                       |
 |  +----------------+   |  +-----------------------+
 |  |    Callouts    |   |  | CalloutParticipations |
 |  +----------------+   |  +-----------------------+
 |  | * id           |-+ |  | * id                  |-+
 |  | * status       | | |  | * msisdn              | |
 |  | * metadata     | | |  | * metadata            | |
 |  |                | | +->| * contact_id          | |
 |  |                | +--->| * callout_id          | |
 |  |                |      |                       | |
 |  +----------------+      +---------------------- + |
 |                                                    |
 |  +----------------------------+                    |
 |  |         PhoneCalls         |                    |
 |  +----------------------------+                    |
 |  | * id                       |--+                 |
 |  | * status                   |  |                 |
 |  | * callout_participation_id |<-+-----------------+
 +->| * contact_id               |  |
    | * ...                      |  |
    +----------------------------+  |
                                    |
    +----------------------------+  |
    |     PhoneCallEvents        |  |
    +----------------------------+  |
    | * id                       |  |
    | * metadata                 |  |
    | * phone_call_id            |<-+
    | * ...                      |
    +----------------------------+
</pre>

## Features

* Create contacts with custom metadata
* Use participations to populate callouts with your contacts
* *start*, *stop*, *pause* and *resume* callouts
* Extend with your own [tasks](https://github.com/dwilkie/somleng-scfm-avf/tree/master/app/tasks)
* Add your own metadata as JSON to all objects
* Create dynamic call flows with *phone call events*

## Usage

See [USAGE](https://github.com/dwilkie/somleng-scfm-avf/blob/master/docs/USAGE.md)

## Deployment

See [DEPLOYMENT](https://github.com/dwilkie/somleng-scfm-avf/blob/master/docs/DEPLOYMENT.md)

## License

The software is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
