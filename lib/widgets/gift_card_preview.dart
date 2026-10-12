import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class GiftCardPreview extends StatelessWidget {
  final String recipient;
  final String message;
  final String sender;
  final String cardDesign;
  final bool hasWaxSeal;
  final String waxSealColor;
  final String ribbonText;

  const GiftCardPreview({
    super.key,
    required this.recipient,
    required this.message,
    required this.sender,
    this.cardDesign = 'Classic Floral',
    this.hasWaxSeal = true,
    this.waxSealColor = 'Antique Gold',
    this.ribbonText = '',
  });

  Color _getSealColor() {
    switch (waxSealColor.toLowerCase()) {
      case 'burgundy red':
        return const Color(0xFF8B1E2F);
      case 'forest sage':
        return const Color(0xFF2D4A3E);
      case 'champagne pearl':
        return const Color(0xFFD9C8B4);
      case 'antique gold':
      default:
        return const Color(0xFFC59B27);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ribbon Banner (if provided)
        if (ribbonText.trim().isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFC59B27), Color(0xFFE8D49E), Color(0xFFC59B27)],
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🎀 ', style: TextStyle(fontSize: 14)),
                Flexible(
                  child: Text(
                    'Embroidered Silk Ribbon: "$ribbonText"',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cinzel(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF3B2E0B),
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Greeting Card Container
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFFCFAF6),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2D9CC), width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A1E2822),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Decorative Card Border
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFD6CABA).withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),

              // Corner botanical flourishes
              const Positioned(
                top: 14,
                left: 14,
                child: Opacity(
                  opacity: 0.4,
                  child: Text('🌿', style: TextStyle(fontSize: 14)),
                ),
              ),
              const Positioned(
                top: 14,
                right: 14,
                child: Opacity(
                  opacity: 0.4,
                  child: Text('🌸', style: TextStyle(fontSize: 14)),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card header title
                    Center(
                      child: Text(
                        'BLOOM & RIBBON BESPOKE NOTE',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          letterSpacing: 2.0,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accentGold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Salutation
                    Text(
                      recipient.trim().isEmpty ? 'Dearest recipient,' : 'Dearest $recipient,',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 17,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Body Message
                    Text(
                      message.trim().isEmpty
                          ? 'Your heartfelt custom message will appear here beautifully handwritten on our artisan stationery.'
                          : message,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 16,
                        height: 1.4,
                        fontStyle: FontStyle.italic,
                        color: const Color(0xFF2C332E),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Sign-off
                    Align(
                      alignment: Alignment.centerRight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'With deepest adoration,',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            sender.trim().isEmpty ? '— Your Admirer' : '— $sender',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Wax Seal Stamp (if enabled)
              if (hasWaxSeal)
                Positioned(
                  bottom: 12,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _getSealColor(),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _getSealColor().withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1),
                      ),
                      child: const Text(
                        '⚜️',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
