import 'package:flutter/material.dart';

class StaticLists {
  static List<String> getCategories() {
    return [
      'Blusa',
      'Body',
      'Calça',
      'Conjunto',
      'Cropped',
      'Macaquinho',
      'Short',
      'Kimono',
      'Vestido',
      'Outro',
      // 'Bomber',
      // 'T-Shirt',
    ];
  }

  static List<String> getSizes() {
    return [
      'P',
      'M',
      'G',
      'GG',
      '46',
      '44',
      '42',
      '40',
      '38',
      '36',
      '34',
    ];
  }

  static List<String> getTypes() {
    return [
      'Lycra',
      'Linho',
      'Viscolycra',
      'Viscose',
      'Jeans',
      'Tricô',
      'Outro'
    ];
  }

  static List<String> getPrices() {
    return [
      '9.99',
      '14.99',
      '19.99',
      '24.99',
      '29.99',
      '34.99',
      '39.99',
      '49.99',
      '59.99',
      '69.99',
      '79.99',
      '89.99',
      '99.99'
    ];
  }

  static List<Map<String, dynamic>> getPayments() {
    return [
      {'payment': 'Dinheiro', 'color': Colors.green},
      {'payment': 'Débito', 'color': Colors.blueAccent},
      {'payment': 'Crédito', 'color': Colors.indigo},
      {'payment': 'Parcelado', 'color': Colors.orange},
      {'payment': 'Picpay', 'color': Colors.lime},
      {'payment': 'Banescard', 'color': Colors.lightBlue},
      {'payment': 'Desconto', 'color': Colors.red},
      {'payment': 'Outro', 'color': Colors.blueGrey},
      {'payment': 'Troca', 'color': Colors.black},
    ];
  }

  static List<Map<String, dynamic>> getAccounts() {
    return [
      {'account': 'Caixa', 'color': Colors.green},
      {'account': 'Sangria', 'color': Colors.indigo},
      {'account': 'Conta', 'color': Colors.blue},
      {'account': 'Picpay', 'color': Colors.lime},
      {'account': 'Outra', 'color': Colors.black},
    ];
  }

  static List<Map<String, dynamic>> getColors() {
    return [
      {'label': 'Amarelo', 'color': Colors.yellow},
      {'label': 'Azul', 'color': Colors.blueAccent[700]},
      {'label': 'Ciano', 'color': Colors.cyan},
      {'label': 'Cinza', 'color': Colors.grey},
      {'label': 'Laranja', 'color': Colors.orange},
      {'label': 'Marrom', 'color': Colors.brown},
      {'label': 'Preto', 'color': Colors.black},
      {'label': 'Rosa', 'color': Colors.pink},
      {'label': 'Roxo', 'color': Colors.purple},
      {'label': 'Vermelho', 'color': Colors.redAccent[700]},
      {'label': 'Verde', 'color': Colors.green},
      // {'label': 'Mostarda', 'color': Colors.lime[700]},
      // {'label': 'Salmão', 'color': Colors.red[200]},
      // {'label': 'Telha', 'color': Colors.deepOrange[900]},
    ];
  }

  static Map<String, dynamic> getTypesCashOut2() {
    return {
      'Despesa com Pessoal': [
        'Salário',
        'Transporte',
        'Comissão',
      ],
      'Despesas Básicas': [
        'Água',
        'Aluguel',
        'Energia',
        'Internet',
        'IPTU',
        'Recarga Telefone'
      ],
      'Transferência': [
        'Entre contas',
        'Envelope de saída',
      ],
      'Reposição': [
        'Mercadorias',
        'Despesas de Viagem',
        'Passagem',
        'Alimentação',
        'Acessoria'
      ],
      'Materiais': [
        'Material de escritório',
        'Material de limpeza',
        'Material de higiene',
        'Material de operação'
      ],
      'Outras': ['Outras']
    };
  }

  static List<String> fieldNuvemShop() {
    return [
      'Identificador URL',
      'Nome',
      'Categorias',
      'Nome da variação 1',
      'Valor da variação 1',
      'Nome da variação 2',
      'Valor da variação 2',
      'Preço',
      'Preço promocional',
      'Estoque',
      'Exibir na loja',
      'Frete gratis',
      'Descrição',
      'Produto Físico',
    ];
  }

  static List<DateTime> daysOfMonth(int month, int year) {
    final _startDate = DateTime(year, month, 1);
    final _endDate = DateTime(year, month + 1).isAfter(DateTime.now())
        ? DateTime.now()
        : DateTime(year, month + 1).subtract(Duration(days: 1));

    return List.generate(
      _endDate.difference(_startDate).inDays + 1,
      (i) => DateTime(_startDate.year, _startDate.month, _startDate.day + (i)),
    );
  }
}
