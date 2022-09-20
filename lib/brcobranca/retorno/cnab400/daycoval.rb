# -*- encoding: utf-8 -*-
require 'parseline'

module Brcobranca
  module Retorno
    module Cnab400
      # Formato de Retorno CNAB 400
      # Baseado em: http://download.itau.com.br/bankline/layout_cobranca_400bytes_cnab_itau_mensagem.pdf
      class Daycoval < Brcobranca::Retorno::Cnab400::Base
        extend ParseLine::FixedWidth # Extendendo parseline

        # Load lines
        def self.load_lines(file, options = {})
          default_options = { except: [1] } # por padrao ignora a primeira linha que é header
          options = default_options.merge!(options)
          super file, options
        end

        fixed_width_layout do |parse|
          # Todos os campos descritos no documento em ordem
          # identificacao do registro transacao
          # começa do 0 então contar com +1 as posições
          parse.field :codigo_registro, 0..0
          parse.field :tipo_de_empresa, 1..2
          parse.field :cpf_cnpf, 3..16
          #parse.field :brancos, 17..36 [BRANCOS]
          #parse.field :uso_da_empresa, 37..61 [BRANCOS]
          parse.field :nosso_numero, 62..72
          #parse.field :brancos, 73..81 [BRANCOS]
          parse.field :nossa_carteira, 82..84
          #parse.field :brancos, 85..106 [BRANCOS]
          parse.field :carteira, 107..107
          parse.field :codigo_ocorrencia, 108..109
          parse.field :data_ocorrencia, 110..115
          parse.field :seu_numero, 116..125
          #parse.field :brancos, 126..145 [BRANCOS]
          parse.field :data_vencimento, 146..151
          parse.field :valor_titulo, 152..164
          parse.field :banco_recebedor, 165..167
          parse.field :agencia_recebedora_com_dv, 168..172
          parse.field :especie_documento, 173..174
          parse.field :tarifa_cobranca, 175..187
          #parse.field :brancos, 188..213 [BRANCOS]
          parse.field :iof, 214..226
          #parse.field :zeros, 227..239 [ZEROS]
          parse.field :desconto, 240..252
          parse.field :valor_recebido, 253..265
          parse.field :juros_mora, 266..278
          #parse.field :complementos, 279..375 [ZEROS]
          parse.field :codigo_moeda, 376..376
          parse.field :erro_retorno, 377..384
          parse.field :data_credito, 385..390
          #parse.field :filler, 391..393 [ZEROS]
          parse.field :sequencial, 394..399
        end
      end
    end
  end
end
