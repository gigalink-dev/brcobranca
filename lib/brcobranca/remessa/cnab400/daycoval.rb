# -*- encoding: utf-8 -*-
module Brcobranca
  module Remessa
    module Cnab400
      class Daycoval < Brcobranca::Remessa::Cnab400::Base
        attr_accessor :codigo_empresa

        validates_presence_of :agencia, :conta_corrente, message: 'não pode estar em branco.'
        validates_presence_of :documento_cedente, :digito_conta, message: 'não pode estar em branco.'
        validates_length_of :agencia, maximum: 4, message: 'deve ter 4 dígitos.'
        validates_length_of :conta_corrente, maximum: 6, message: 'deve ter 6 dígitos.'
        validates_length_of :documento_cedente, minimum: 11, maximum: 14, message: 'deve ter entre 11 e 14 dígitos.'
        validates_length_of :carteira, maximum: 3, message: 'deve ter no máximo 3 dígitos.'
        validates_length_of :digito_conta, maximum: 1, message: 'deve ter 1 dígito.'

        # Nova instancia do Daycoval
        def initialize(campos = {})
          super(campos)
        end

        ####
        # Métodos Header
        ####

        # Informacoes da conta corrente do cedente
        #
        # @return [String]
        #
        def info_conta
          codigo_empresa.format_size(20)
        end

        def cod_banco
          '707'
        end

        def nome_banco
          'BANCO DAYCOVAL'.format_size(15)
        end

        # Complemento do header
        # (no caso do Daycoval, sao apenas espacos em branco)
        #
        # @return [String]
        #
        def complemento
          ''.format_size(294)
        end

        ####
        # Métodos Header Fim
        ####

        # Detalhe do arquivo
        #
        # @param pagamento [PagamentoCnab400]
        #   objeto contendo as informacoes referentes ao boleto (valor, vencimento, cliente)
        # @param sequencial
        #   num. sequencial do registro no arquivo
        #
        # @return [String]
        #
        def monta_detalhe(pagamento, sequencial)
          raise Brcobranca::RemessaInvalida, pagamento if pagamento.invalid?

          detalhe = '1'                                                     # identificacao transacao               9[01]
          detalhe << Brcobranca::Util::Empresa.new(documento_cedente).tipo  # Código de Inscrição                   9[02]
          detalhe << documento_cedente.to_s.rjust(14, '0')                  # Número de Inscrição                   9[14]
          detalhe << info_conta                                             # Código da Empresa                     X[20] 
          detalhe << ''.rjust(25, ' ')                                      # Uso da Empresa                        X[25] 
          detalhe << pagamento.nosso_numero.to_s.format_size(8)             # Nosso Número                          9[08] 
          detalhe << ''.rjust(13, ' ')                                      # BRANCOS                               X[13]  
          detalhe << ''.rjust(24, ' ')                                      # Uso do Banco                          X[24] 

          # Na posição 108, campo "Código da emissão de boleto" deve ser "6”

          detalhe << '6'                                                    # Código de remessa                     X[01] 

          # CÓDIGO:              OCORRÊNCIA P/ COMANDO DE INSTRUÇÕES:
          # 01:                  Remessa 
          # 02:                  Pedido de Baixa 
          # 04:                  Concessão de Abatimento 
          # 06:                  Alteração de Vencimento 
          # 09:                  Protestar 
          # 10:                  Pedido de não protestar 
          # 18:                  Sustar protesto

          detalhe << pagamento.identificacao_ocorrencia                     # Código de Ocorrência                  9[02] 

          detalhe << pagamento.documento.to_s.format_size(10)                         # Seu Número                            X[10] 
          detalhe << pagamento.data_vencimento.strftime('%d%m%y')           # Vencimento                            9[06] 
          detalhe << pagamento.formata_valor                                # Valor do título (**)                  9[11] V9[02] 
          detalhe << cod_banco                                              # Código do Banco                       9[03] 
          detalhe << ''.rjust(4, '0')                                       # Agência Cobradora                     9[04] 
          detalhe << '0'                                                    # Dac da Ag. Cobradora                  9[01]

          # CÓDIGO:      ESPÉCIE
          # 01:          Duplicata 
          # 05:          Recibo 
          # 12:          Duplicata de Serviço 
          # 99:          Outros 
          detalhe << pagamento.especie_titulo                               # Espécie                               X[02]


          detalhe << 'N'                                                    # Aceite                                X[01] 
          detalhe << pagamento.data_emissao.strftime('%d%m%y')              # Data de Emissão                       9[06]
          detalhe << ''.rjust(2, '0')                                       # ZEROS                                 9[02]
          detalhe << ''.rjust(2, '0')                                       # ZEROS                                 9[02] 
          detalhe << ''.rjust(13, '0')                                      # Juros de 1 dia (**)                   9[11] V9[02]
          detalhe << pagamento.formata_data_desconto                        # Desconto até                          9[06] 
          detalhe << pagamento.formata_valor_desconto                       # Valor do desconto                     9[11] V9[02]
          detalhe << ''.rjust(13, '0')                                      # Uso do Banco [ZEROS]                  9[13] 
          detalhe << pagamento.formata_valor_abatimento                     # Valor de Abatimento                   9[11] V9[02]
          detalhe << pagamento.identificacao_sacado.rjust(2, '0')           # Código de Inscrição                   9[02]
          detalhe << pagamento.documento_sacado.to_s.rjust(14, '0')         # Número Inscrição CNPJ ou CPF          9[14]
          detalhe << pagamento.nome_sacado.format_size(30).ljust(30, ' ')   # Nome                                  X[30]
          detalhe << ''.rjust(10, ' ')                                      # Brancos                               X[10]
          detalhe << pagamento.endereco_sacado.format_size(40)              # Logradouro                            X[40]
          detalhe << pagamento.bairro_sacado.format_size(12)                # Bairro                                X[12]
          detalhe << pagamento.cep_sacado                                   # CEP                                   9[08]
          detalhe << pagamento.cidade_sacado.format_size(15)                # Cidade                                X[15]
          detalhe << pagamento.uf_sacado                                    # Estado                                X[02]
          detalhe << empresa_mae.format_size(30)                            # Sacador ou Avalista                   X[30]
          detalhe << ''.rjust(4, ' ')                                       # Brancos                               X[04]
          detalhe << ''.rjust(6, ' ')                                       # Brancos                               X[06]
          detalhe << ''.rjust(2, '0')                                       # Prazo [ZEROS]                         9[02]
          detalhe << '0'                                                    # Moeda  [0 - Moeda Corrente Nacional]  X[01]
          detalhe << sequencial.to_s.rjust(6, '0')                          # Número Sequencial                     9[06]

          detalhe
        end
      end
    end
  end
end
