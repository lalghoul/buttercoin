Q = require('q')
Protocol = require('../../ews/protocol')
ApiProtocol = require('../api_protocol')
ProxyConnection = require('../../proxy_connection')
MtGoxAdaptor = require('./adaptor')

module.exports = class MtGoxProtocol extends Protocol
  constructor: (options, parent) ->
    super(options, parent)
    options.api ||= {}

    @api = new ApiProtocol(options.api, this)
    @adaptor = new MtGoxAdaptor()
    @proxy = new ProxyConnection()
    @proxy.on('received_data', @handle_proxied_data)

  start: (connection) =>
    @error "GOX PROTOCOL TOTALLY GONNA START BRAH"
    @proxy.connect()
    Q.all([
      super(connection)
      @api.start(@proxy) ]).then => @error "GOX PROTOCOL TOTALLY STARTED BRAH"

  handle_open: (connection) =>
    @warn "THIS CONNECTION>>> IS OPEN!!!"
    @protocol_ready.resolve(this)

  handle_proxied_data: (data) =>
    @info "PROTOCOL SAID:", data
    @connection.send_obj(@adaptor.translate_outbound(data))

  handle_parsed_data: (data) =>
    @info "CLIENT SAID:", data
    @proxy.emit(
      'transport_message',
      @adaptor.translate_inbound(data))

