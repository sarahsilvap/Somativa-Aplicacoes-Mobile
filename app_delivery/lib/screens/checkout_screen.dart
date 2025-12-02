import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../services/zip_code_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _houseNumberController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _zipController = TextEditingController();
  bool _isProcessing = false;
  bool _isLookingUpZip = false;
  double _deliveryFee = 0.0;
  bool _addressConfirmed = false;

  @override
  void dispose() {
    _addressController.dispose();
    _houseNumberController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _neighborhoodController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  double _calculateDeliveryFee() {
    final city = _cityController.text.toLowerCase();
    final state = _stateController.text.toLowerCase();

    if (city.contains('são paulo') || city.contains('sp')) {
      return 5.00;
    } else if (state.contains('sp')) {
      return 8.00;
    } else {
      return 10.00;
    }
  }

  Future<void> _lookupZipCode(String zipCode) async {
    if (zipCode.length < 8) return;

    setState(() => _isLookingUpZip = true);

    try {
      final addressData = await ZipCodeService.lookupZipCode(zipCode);

      if (!mounted) return;

      _addressController.text = addressData['street'] ?? '';
      _neighborhoodController.text = addressData['neighborhood'] ?? '';
      _cityController.text = addressData['city'] ?? '';
      _stateController.text = addressData['state'] ?? '';

      setState(() {
        _deliveryFee = _calculateDeliveryFee();
        _addressConfirmed = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Endereço encontrado! Taxa de entrega: R\$ ${_deliveryFee.toStringAsFixed(2)}'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Não foi possível encontrar o CEP: ${e.toString()}'),
          backgroundColor: Colors.orange,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLookingUpZip = false);
      }
    }
  }

  String get fullAddress {
    return '${_addressController.text}, ${_houseNumberController.text}, ${_neighborhoodController.text}, ${_cityController.text} - ${_stateController.text}, ${_zipController.text}';
  }

  double get finalDeliveryFee {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    if (cartProvider.totalAmount >= 100.00) {
      return 0.0;
    }
    return _deliveryFee;
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_addressConfirmed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Por favor, insira um CEP válido para confirmar seu endereço'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final subtotal = cartProvider.totalAmount;
      final deliveryFee = finalDeliveryFee;
      final total = subtotal + deliveryFee;

      // Simulate processing time
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      // Clear the cart
      cartProvider.clear();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          icon: const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 64,
          ),
          title: const Text('Pedido Realizado!'),
          content: Text(
            'Seu pedido foi realizado com sucesso.\n\nTotal: R\$ ${total.toStringAsFixed(2)}\n\nEndereço: $fullAddress\n\nVocê receberá uma confirmação em breve.',
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/home',
                  (route) => false,
                );
              },
              child: const Text('Continuar Comprando'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao finalizar pedido: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final subtotal = cartProvider.totalAmount;
    final deliveryFee = finalDeliveryFee;
    final grandTotal = subtotal + deliveryFee;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finalizar Pedido'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Endereço de Entrega',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _zipController,
                      decoration: InputDecoration(
                        labelText: 'CEP',
                        hintText: 'Digite o CEP com 8 dígitos',
                        helperText: 'Digite seu CEP para preencher o endereço',
                        prefixIcon: const Icon(Icons.pin_drop),
                        suffixIcon: _isLookingUpZip
                            ? const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : _addressConfirmed
                                ? const Icon(Icons.check_circle,
                                    color: Colors.green)
                                : const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 8,
                      onChanged: (value) {
                        if (_addressConfirmed && value.length != 8) {
                          setState(() {
                            _addressConfirmed = false;
                            _deliveryFee = 0.0;
                          });
                        }
                        if (value.length == 8) {
                          _lookupZipCode(value);
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o CEP';
                        }
                        if (value.length != 8) {
                          return 'O CEP deve ter 8 dígitos';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'Rua',
                        hintText: 'Será preenchido automaticamente',
                        prefixIcon: const Icon(Icons.route_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      readOnly: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o CEP para obter o endereço';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _houseNumberController,
                      decoration: InputDecoration(
                        labelText: 'Número *',
                        hintText: 'Digite o número da casa/apartamento',
                        prefixIcon: const Icon(Icons.home_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o número';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _neighborhoodController,
                      decoration: InputDecoration(
                        labelText: 'Bairro',
                        hintText: 'Será preenchido automaticamente',
                        prefixIcon: const Icon(Icons.location_on_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      readOnly: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o CEP para obter o bairro';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _cityController,
                            decoration: InputDecoration(
                              labelText: 'Cidade',
                              hintText: 'Preenchido automaticamente',
                              prefixIcon:
                                  const Icon(Icons.location_city_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            readOnly: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Obrigatório';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _stateController,
                            decoration: InputDecoration(
                              labelText: 'Estado',
                              hintText: 'UF',
                              prefixIcon: const Icon(Icons.map_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            readOnly: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Obrigatório';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Resumo do Pedido',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Subtotal (${cartProvider.itemCount} itens)',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                Text(
                                  'R\$ ${subtotal.toStringAsFixed(2)}',
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Taxa de Entrega',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                Text(
                                  deliveryFee == 0.0
                                      ? 'A Calcular'
                                      : 'R\$ ${deliveryFee.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: deliveryFee == 0.0
                                        ? Colors.green
                                        : Theme.of(context).colorScheme.primary,
                                    fontWeight: deliveryFee == 0.0
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                            if (subtotal >= 100.00 && _addressConfirmed)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Icon(Icons.check_circle,
                                        size: 16, color: Colors.green),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Entrega grátis (pedidos acima de R\$ 100)',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.green[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  'R\$ ${grandTotal.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (subtotal < 100.00 && _addressConfirmed)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.local_shipping,
                                color: Colors.orange[700]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Adicione R\$ ${(100.00 - subtotal).toStringAsFixed(2)} para entrega GRÁTIS!',
                                style: TextStyle(
                                  color: Colors.orange[900],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _isProcessing ? null : _placeOrder,
                  child: _isProcessing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Finalizar Pedido - R\$ ${grandTotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
