import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'Cubit/user_cubit.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserCubit()..loadUserInfo(),
      child: const _UserPageView(),
    );
  }
}

class _UserPageView extends StatelessWidget {
  const _UserPageView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        if (state is UserLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is UserLoaded) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Tên: ${state.name ?? 'N/A'}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Email: ${state.email ?? 'N/A'}',
                style: const TextStyle(fontSize: 16),
              ),
              if (state.createdAt != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Ngày tạo: ${state.createdAt}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.read<UserCubit>().refreshUserInfo(),
                child: const Text('Làm mới'),
              ),
            ],
          );
        } else if (state is UserError) {
          return Center(
            child: Text(
              'Lỗi: ${state.message}',
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          );
        }

        return const Center(child: Text('Khởi tạo...'));
      },
    );
  }
}
