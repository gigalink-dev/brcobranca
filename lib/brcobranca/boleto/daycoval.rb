# -*- encoding: utf-8 -*-
#
module Brcobranca
  module Boleto
    class Daycoval < Base

      validates_length_of :agencia, maximum: 4, message: 'deve ser menor ou igual a 4 dígitos.'
      validates_length_of :conta_corrente, maximum: 7, message: 'deve ser menor ou igual a 7 dígitos.'
      validates_length_of :carteira, is: 3, message: 'deve ser menor ou igual a 3 dígitos.'
      validates_length_of :nosso_numero, maximum: 10, message: 'deve ser menor ou igual a 10 dígitos.'


      def initialize(campos = {})
        super(campos)
      end

      # Codigo do banco emissor (3 dígitos sempre)
      #
      # @return [String] 3 caracteres numéricos.
      def banco
        '707'
      end

      # Dígito verificador do banco
      #
      # @return [String] 1 caractere.
      def banco_dv
        '2'
      end

      # Agência
      #
      # @return [String] 4 caracteres numéricos.
      def agencia=(valor)
        @agencia = valor.to_s.rjust(4, '0') if valor
      end

      # Número documento
      #
      # @return [String] 7 caracteres numéricos.
      def nosso_numero=(valor)
        @nosso_numero = valor.to_s.rjust(10, '0') if valor
      end

      # Nosso número para exibição no boleto.
      #
      # @return [String] 8 caracteres numéricos.
      def nosso_numero_boleto
        "#{carteira}/#{nosso_numero}-#{nosso_numero_dv}"
      end

      ##
      # ROTINA PARA CÁLCULO DO DV DO NOSSO NÚMERO
      # Sejam eles:
      # AAAA = Código da agência do título, sem DV.
      # CCC = Código da carteira (vide e-mail)
      # NNNNNNNNNN O nosso número, sem DV
      # Multiplica-se cada algarismo do número formado pela composição dos campos acima pela sequência
      # de multiplicadores 2,1,2,1,2,1,2 (posicionados da direita para a esquerda).
      # . Se a multiplicação resultar > 9 (por exemplo = 12), somar os dígitos (1 + 2).
      # . A seguir, soma-se os algarismos dos produtos e o total obtido é dividido por 10. O DV é a diferença
      # entre o divisor (10) e o resto da divisão:
      # 10 - (RESTO DA DIVISAO) = DV. Se o resto da divisão for zero, o DV é zero.
      # EXEMPLO: Agência: 0001.9 Carteira = 121 Nosso Número = 0004309540
      def nosso_numero_dv
        "#{agencia}#{carteira}#{nosso_numero}".modulo10
      end

      def agencia_conta_boleto
        "#{agencia}-9 / #{conta_corrente}-7"
      end

      # FICHA DE COMPENSAÇÃO – CÓDIGO DE BARRAS
      # Código do banco
      # Moeda
      # DV do código de barras
      # Fator de Vencimento
      # Valor do título
      # Campo livre
      # 3 posições = 707
      # 1 posição = 9
      # 1 posição (vide abaixo)
      # 4 posições
      # 10 posições (sendo 2 casas
      # decimais)
      # 25 posições, onde:
      # Agência sem DV – 4 posições (vide
      # e-mail)
      # Carteira – 3 posições (vide e-mail)
      # Operação – 7 posições (vide e-
      # mail)
      # Nosso Número + DV – 11 posições
      # (utilizar o range disponibilizado –
      # vide e-mail)
      def codigo_barras_segunda_parte
        "#{agencia}#{carteira}#{convenio}#{nosso_numero}#{nosso_numero_dv}"
      end
    end
  end
end
