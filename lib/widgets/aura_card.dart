import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memory_game/bloc/aura/aura_bloc.dart';

class AuraCard extends StatelessWidget {
  const AuraCard({super.key});

  @override
  Widget build(BuildContext context) {
    final auraBloc = context.read<AuraBloc>();
    auraBloc.startAnimation();

    return BlocBuilder<AuraBloc, AuraState>(
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.5 + state.animationValue * 0.5),
                blurRadius: 20 + state.animationValue * 10,
                spreadRadius: state.animationValue * 5,
              ),
            ],
          ),
          child: const Card(
            child: SizedBox(
              width: 200,
              height: 300,
              child: Center(child: Text('Aura Card')),
            ),
          ),
        );
      },
    );
  }
}
