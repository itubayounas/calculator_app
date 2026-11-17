import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../services/calculator_engine.dart';
import '../services/history_service.dart';
import '../utils/exceptions.dart';
import '../utils/ui_helpers.dart';
import '../widgets/calc_button.dart';
import '../widgets/display_panel.dart';
import 'history_screen.dart';

class CalculatorScreen extends StatefulWidget {
  final AppUser user;
  final AuthService authService;
  final HistoryService historyService;

  const CalculatorScreen({
    super.key,
    required this.user,
    required this.authService,
    required this.historyService,
  });

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final CalculatorEngine _engine = CalculatorEngine();

  String _errorText = '';
  bool _showError = false;

  static const _operators = ['+', '−', '×', '÷'];

  void _onKey(String key) {
    setState(() {
      _showError = false;
      try {
        if (RegExp(r'^[0-9]$').hasMatch(key)) {
          _engine.inputDigit(key);
        } else if (_operators.contains(key)) {
          _engine.inputOperator(key);
        } else {
          switch (key) {
            case '.':
              _engine.inputDecimal();
              break;
            case '±':
              _engine.toggleSign();
              break;
            case '%':
              _engine.percent();
              break;
            case '⌫':
              _engine.backspace();
              break;
            case 'C':
              _engine.clear();
              break;
          }
        }
      } on CalculatorException catch (e) {
        _errorText = e.message;
        _showError = true;
      }
    });
  }

  Future<void> _onEquals() async {
    CalculationResult? result;
    try {
      result = _engine.equals();
      setState(() => _showError = false);
    } on CalculatorException catch (e) {
      setState(() {
        _errorText = e.message;
        _showError = true;
      });
      return;
    }
    if (result == null) return;

    // the calculation is already done; saving must never block or break it
    try {
      await widget.historyService.add(
        widget.user.uid,
        result.expression,
        result.result,
      );
    } on HistorySyncException catch (e) {
      if (mounted) showNotice(context, e.message);
    }
  }

  Future<void> _openHistory() async {
    final value = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => HistoryScreen(
          user: widget.user,
          historyService: widget.historyService,
        ),
      ),
    );
    if (value != null) {
      setState(() {
        _showError = false;
        _engine.loadValue(value);
      });
    }
  }

  CalcButtonType _typeFor(String key) {
    if (key == '=') return CalcButtonType.equals;
    if (_operators.contains(key)) return CalcButtonType.operator;
    if (['C', '⌫', '%', '±'].contains(key)) return CalcButtonType.function;
    return CalcButtonType.number;
  }

  @override
  Widget build(BuildContext context) {
    const rows = [
      ['C', '⌫', '%', '÷'],
      ['7', '8', '9', '×'],
      ['4', '5', '6', '−'],
      ['1', '2', '3', '+'],
      ['±', '0', '.', '='],
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
        actions: [
          IconButton(
            tooltip: 'History',
            icon: const Icon(Icons.history),
            onPressed: _openHistory,
          ),
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () => widget.authService.signOut(),
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.25),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: DisplayPanel(
                      greeting: 'Hi, ${widget.user.friendlyName} 👋',
                      expression: _engine.expression,
                      value: _engine.display,
                      errorText: _errorText,
                      showError: _showError,
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      child: Column(
                        children: [
                          for (final row in rows)
                            Expanded(
                              child: Row(
                                children: [
                                  for (final key in row)
                                    Expanded(
                                      child: CalcButton(
                                        label: key == 'C' && !_engine.canClearEntry
                                            ? 'AC'
                                            : key,
                                        type: _typeFor(key),
                                        onPressed: key == '='
                                            ? _onEquals
                                            : () => _onKey(key),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}