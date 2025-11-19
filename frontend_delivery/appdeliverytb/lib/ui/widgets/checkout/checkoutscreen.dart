import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:appdeliverytb/provider/bag_provider.dart';
import 'package:appdeliverytb/model/product_model.dart';

class Checkoutscreen extends StatefulWidget {
  const Checkoutscreen({super.key});

  @override
  State<Checkoutscreen> createState() => _CheckoutscreenState();
}

class _CheckoutscreenState extends State<Checkoutscreen> {
  final TextEditingController _cepCtrl = TextEditingController();
  bool _loadingCep = false;
  String? _cepError;
  Map<String, dynamic>? _address;
  double _deliveryFee = 0.0;

  // ======================= BUSCAR CEP ===========================
  Future<void> _fetchCep() async {
    final cepRaw = _cepCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cepRaw.length != 8) {
      setState(() {
        _cepError = 'CEP inválido (8 dígitos)';
      });
      return;
    }

    setState(() {
      _loadingCep = true;
      _cepError = null;
      _address = null;
    });

    try {
      final uri = Uri.parse('https://viacep.com.br/ws/$cepRaw/json/');
      final resp = await http.get(uri);

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);

        if (data != null && data['erro'] == null) {
          setState(() {
            _address = data;
            _cepError = null;
          });

          // ==================== CÁLCULO DA TAXA ======================
          final bairroCliente = data['bairro'] ?? '';
          final cidadeCliente = data['localidade'] ?? '';

          const restauranteBairro = "Vila Rialto";
          const restauranteCidade = "Campinas";

          double taxa = 0;

          if (cidadeCliente != restauranteCidade) {
            taxa = 8.0; // cidade diferente
          } else if (bairroCliente != restauranteBairro) {
            taxa = 4.0; // bairro diferente
          } else {
            taxa = 0.0; // mesmo bairro
          }

          setState(() {
            _deliveryFee = taxa;
          });

        } else {
          setState(() {
            _cepError = 'CEP não encontrado';
          });
        }
      } else {
        setState(() => _cepError = "Erro ao consultar CEP");
      }
    } catch (e) {
      setState(() => _cepError = e.toString());
    } finally {
      setState(() => _loadingCep = false);
    }
  }

  String _addressDisplay() {
    if (_address == null) return '';
    return "${_address?['logradouro']}, "
        "${_address?['bairro']} — "
        "${_address?['localidade']}/${_address?['uf']}";
  }

  // ===================== CONFIRMAR PEDIDO ============================
  void _confirmOrder() async {
    final bag = Provider.of<BagProvider>(context, listen: false);
    final subtotal = bag.totalPrice;
    final finalTotal = subtotal + _deliveryFee;

    if (_address == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Informe um CEP válido primeiro.")),
      );
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirmar Pedido"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Endereço: ${_addressDisplay()}"),
            const SizedBox(height: 10),
            Text("Subtotal: R\$ ${subtotal.toStringAsFixed(2)}"),
            Text("Entrega: R\$ ${_deliveryFee.toStringAsFixed(2)}"),
            const Divider(),
            Text(
              "Total: R\$ ${finalTotal.toStringAsFixed(2)}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            )
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancelar")),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Confirmar"))
        ],
      ),
    );

    if (confirmar == true) {
      bag.clearBag();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pedido confirmado!")),
      );

      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _cepCtrl.dispose();
    super.dispose();
  }

  // ===================== UI ============================
  @override
  Widget build(BuildContext context) {
    final bag = context.watch<BagProvider>();
    final subtotal = bag.totalPrice;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          children: [
            // LISTA DE ITENS
            Expanded(
              child: bag.items.isEmpty
                  ? const Center(child: Text("Carrinho vazio"))
                  : ListView.separated(
                      itemCount: bag.items.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (_, index) {
                        final id = bag.items.keys.elementAt(index);
                        final ProductModel product = bag.items[id]!;
                        final qty = bag.quantities[id] ?? 1;

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: AssetImage('assets/${product.image}'),
                          ),
                          title: Text(product.name),
                          subtitle: Text("R\$ ${product.price.toStringAsFixed(2)}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () {
                                  context.read<BagProvider>().removeOne(product);
                                },
                              ),
                              Text(qty.toString(),
                                  style: const TextStyle(fontSize: 16)),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  context.read<BagProvider>().addItem(product);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 12),

            // CAMPO CEP
            TextFormField(
              controller: _cepCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "CEP",
                suffixIcon: _loadingCep
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: _fetchCep,
                      ),
              ),
            ),

            if (_cepError != null)
              Text(_cepError!, style: const TextStyle(color: Colors.red)),

            if (_address != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text("Endereço: ${_addressDisplay()}"),
              ),

            const SizedBox(height: 12),

            // TOTAL
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Subtotal: R\$ ${subtotal.toStringAsFixed(2)}"),
                Text("Entrega: R\$ ${_deliveryFee.toStringAsFixed(2)}"),
              ],
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: bag.items.isEmpty ? null : _confirmOrder,
                child: Text(
                    "Confirmar — Total R\$ ${(subtotal + _deliveryFee).toStringAsFixed(2)}"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
