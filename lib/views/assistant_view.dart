import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/business_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

class AssistantView extends StatefulWidget {
  const AssistantView({super.key});

  @override
  State<AssistantView> createState() => _AssistantViewState();
}

class _AssistantViewState extends State<AssistantView> {
  final TextEditingController _textController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  void _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({"sender": "user", "text": text});
      _textController.clear();
    });

    final provider = Provider.of<BusinessProvider>(context, listen: false);
    
    // Check if it's a sale recording command
    if (text.toLowerCase().contains(" at ") || text.toLowerCase().contains(" ku ") || text.toLowerCase().contains(" à ")) {
      final parsed = await provider.parseVoiceSale(text);
      if (parsed.hasError) {
         setState(() => _messages.add({"sender": "ai", "text": parsed.error}));
      } else {
         setState(() => _messages.add({"sender": "ai", "text": "Understood! Did you sell ${parsed.quantity} ${parsed.productName} for ${parsed.unitPriceBif} BIF each? (Voice saving coming soon!)"}));
      }
    } else {
      final answer = await provider.askAssistant(text);
      setState(() => _messages.add({"sender": "ai", "text": answer}));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('KaBiz Smart Assistant')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.edgeMargin),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['sender'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    padding: const EdgeInsets.all(AppSpacing.gutter),
                    decoration: BoxDecoration(
                      color: isUser ? AppColors.primaryContainer : AppColors.surfaceContainerHigh,
                      borderRadius: AppRadius.borderRadiusLg.copyWith(
                        bottomRight: isUser ? const Radius.circular(0) : null,
                        bottomLeft: !isUser ? const Radius.circular(0) : null,
                      ),
                    ),
                    child: Text(
                      msg['text'], 
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: isUser ? AppColors.onPrimaryContainer : AppColors.onSurface,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(AppSpacing.gutter),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.outlineVariant)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: "Ask 'Who owes me?' or 'Sold 2 fanta at 1500'",
                      filled: true,
                      fillColor: AppColors.surfaceContainerHigh,
                      border: OutlineInputBorder(borderRadius: AppRadius.borderRadiusXl, borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.edgeMargin, vertical: 0),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: AppColors.onPrimary),
                    onPressed: _sendMessage,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
