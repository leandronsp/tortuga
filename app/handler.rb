require 'json'

require_relative 'bank_statement'
require_relative 'transaction'

class Handler 
  VALIDATION_ERRORS = [
    PG::InvalidTextRepresentation,
    PG::StringDataRightTruncation,
    Transaction::InvalidDataError,
    Transaction::InvalidLimitAmountError
  ].freeze

  def self.call(*args)
    new(*args).handle
  end

  def initialize(client)
    @client = client
  end

  def handle
    begin
      ########## Request ##########
      #############################
      message = ''
      headers = {}
      params = {}

      if (line = @client.gets)
        message += line

        headline_regex = /^(GET|POST)\s\/clientes\/(\d+)\/(.*?)\sHTTP.*?$/
        verb, id, action = line.match(headline_regex).captures
        params['id'] = id
        request = "#{verb} /clientes/:id/#{action}"
      end

      puts "\n[#{Time.now}] #{message}"

      while (line = @client.gets)
        break if line == "\r\n"

        header, value = line.split(': ')
        headers[header] = value.chomp

        message += line
      end

      if headers['Content-Length']
        body_size = headers['Content-Length'].to_i
        body = @client.read(body_size)

        params.merge!(JSON.parse(body))
      end

      ########## Response ##########
      ##############################

      status = nil
      body = '{}'

      case request
      in "GET /clientes/:id/extrato"
        body = BankStatement.call(params['id']).to_json

        status = 200
      in "POST /clientes/:id/transacoes"
        body = Transaction.call(
          params['id'], 
          params['valor'], 
          params['tipo'], 
          params['descricao']
        ).to_json

        status = 200
      else 
        status = 404
      end
    rescue PG::ForeignKeyViolation, 
           BankStatement::NotFoundError, 
           Transaction::NotFoundError
      status = 404
    rescue *VALIDATION_ERRORS => err
      status = 422
      body = { error: err.message }.to_json
    end
    
    response = <<~HTTP
      HTTP/2.0 #{status}
      Content-Type: application/json

      #{body}
    HTTP

    @client.puts(response)
  end
end
