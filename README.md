# AmocrmClient

AmoCRM client

### How it use

AmocrmClient uses [anyway_config](https://github.com/palkan/anyway_config) for configuration, so you
can provide configuration parameters through env vars, seperate config file `secrets.yml`.

You must choose the storage where you will store your pair of tokens. Two storages are available: Redis and ActiveRecord (in the model), you must specify in the configuration.

The library itself implements the token refresh mechanism. It also controls the number of requests per second since AMOCRM have limitations (the number of requests can also be adjusted in the configuration)

Create request(See AMOCRM api/v4 documentation)

```ruby
AmocrmClient.connection.request(:get, 'leads/1', {})
```

### Configuration

```
# config/secrets.yml
development:
  ...
  amocrm_client:
    client:
      api_endpoint: 'https://subdomain.amocrm.ru'
      api_path: '/api/v4/'
      request_number: 7
    redis:
      url: 'redis://redishost:6379/0'
    stor_adapter:
      stor: ar
      ar:
        model_name: 'Model Namespace'
      redis:
        key: 'Redis key'
    oauth:
      expires_in: 86400
      redirect_uri: 'https://test.test/'
      path: '/oauth2/access_token'
      client_id: 'client_id-f959-4921-a8f2-e0c8c216bfdf'
      client_secret: 'client_secret'
      init_access_token: 'init_access_token'
      init_refresh_token: 'init_refresh_token'
```