import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:markflow/src/shared/locator.dart';
import 'package:markflow/src/shared/services/app_logger.dart';
import 'package:markflow/src/shared/services/storage/storage.dart';

/// Service for managing SSH keys for Git authentication
class SshKeyService {
  static const String _sshKeyPathKey = 'ssh_key_path';
  static const String _sshKeyEmailKey = 'ssh_key_email';

  final AppLogger _logger;
  final Storage _storage;

  SshKeyService({
    AppLogger? logger,
    Storage? storage,
  })  : _logger = logger ?? locator<AppLogger>(),
        _storage = storage ?? locator<Storage>();

  /// Get the default SSH directory path
  String get defaultSshDirectory {
    final homeDir = Platform.environment['HOME'] ??
        Platform.environment['USERPROFILE'] ??
        '';
    return path.join(homeDir, '.ssh');
  }

  /// Get the stored SSH key path
  Future<String?> getSshKeyPath() async {
    return await _storage.read<String>(key: _sshKeyPathKey);
  }

  /// Set the SSH key path
  Future<void> setSshKeyPath(String keyPath) async {
    await _storage.writeString(key: _sshKeyPathKey, value: keyPath);
    _logger.info('SSH key path updated: $keyPath');
  }

  /// Get the stored SSH key email
  Future<String?> getSshKeyEmail() async {
    return await _storage.read<String>(key: _sshKeyEmailKey);
  }

  /// Set the SSH key email
  Future<void> setSshKeyEmail(String email) async {
    await _storage.writeString(key: _sshKeyEmailKey, value: email);
    _logger.info('SSH key email updated: $email');
  }

  /// Check if SSH key exists at the given path
  Future<bool> sshKeyExists(String keyPath) async {
    try {
      final file = File(keyPath);
      return await file.exists();
    } catch (e) {
      _logger.error('Error checking SSH key existence: $e');
      return false;
    }
  }

  /// Generate a new SSH key pair
  Future<bool> generateSshKey({
    required String email,
    String? keyPath,
    String keyType = 'ed25519',
  }) async {
    try {
      final sshDir = Directory(defaultSshDirectory);
      if (!await sshDir.exists()) {
        await sshDir.create(recursive: true);
        _logger.info('Created SSH directory: ${sshDir.path}');
      }

      final finalKeyPath =
          keyPath ?? path.join(defaultSshDirectory, 'id_$keyType');

      // Check if key already exists
      if (await sshKeyExists(finalKeyPath)) {
        _logger.warning('SSH key already exists at: $finalKeyPath');
        return false;
      }

      final result = await Process.run(
        'ssh-keygen',
        [
          '-t', keyType,
          '-C', email,
          '-f', finalKeyPath,
          '-N', '', // No passphrase for simplicity
        ],
      );

      if (result.exitCode == 0) {
        await setSshKeyPath(finalKeyPath);
        await setSshKeyEmail(email);
        _logger.info('SSH key generated successfully: $finalKeyPath');
        return true;
      } else {
        _logger.error('Failed to generate SSH key: ${result.stderr}');
        return false;
      }
    } catch (e) {
      _logger.error('Error generating SSH key: $e');
      return false;
    }
  }

  /// Get the public key content
  Future<String?> getPublicKeyContent(String keyPath) async {
    try {
      final publicKeyPath = '$keyPath.pub';
      final file = File(publicKeyPath);

      if (await file.exists()) {
        return await file.readAsString();
      } else {
        _logger.warning('Public key file not found: $publicKeyPath');
        return null;
      }
    } catch (e) {
      _logger.error('Error reading public key: $e');
      return null;
    }
  }

  /// Add SSH key to ssh-agent
  Future<bool> addKeyToAgent(String keyPath) async {
    try {
      final result = await Process.run('ssh-add', [keyPath]);

      if (result.exitCode == 0) {
        _logger.info('SSH key added to agent: $keyPath');
        return true;
      } else {
        _logger.error('Failed to add SSH key to agent: ${result.stderr}');
        return false;
      }
    } catch (e) {
      _logger.error('Error adding SSH key to agent: $e');
      return false;
    }
  }

  /// Test SSH connection to a host
  Future<bool> testSshConnection(String host) async {
    try {
      final result = await Process.run(
        'ssh',
        ['-T', 'ConnectTimeout=10', host],
      );

      // For GitHub, exit code 1 with specific message indicates successful authentication
      if (host.contains('github.com')) {
        final output = result.stderr.toString();
        return output.contains('successfully authenticated');
      }

      return result.exitCode == 0;
    } catch (e) {
      _logger.error('Error testing SSH connection: $e');
      return false;
    }
  }

  /// Get list of available SSH keys in the SSH directory
  Future<List<String>> getAvailableSshKeys() async {
    try {
      final sshDir = Directory(defaultSshDirectory);
      if (!await sshDir.exists()) {
        return [];
      }

      final files = await sshDir.list().toList();
      final keyFiles = <String>[];
      final publicKeys = <String>{};

      // First pass: collect all public key names
      for (final file in files) {
        if (file is File) {
          final fileName = path.basename(file.path);
          if (fileName.endsWith('.pub')) {
            publicKeys.add(fileName.substring(0, fileName.length - 4));
          }
        }
      }

      // Second pass: find private keys
      for (final file in files) {
        if (file is File) {
          final fileName = path.basename(file.path);
          
          // Skip files that are clearly not SSH private keys
          if (fileName.endsWith('.pub') ||
              fileName.endsWith('.ppk') ||
              fileName.endsWith('.old') ||
              fileName.endsWith('.info') ||
              fileName == 'known_hosts' ||
              fileName == 'config' ||
              fileName == 'authorized_keys') {
            continue;
          }

          // Include file if:
          // 1. It has a corresponding .pub file, OR
          // 2. It matches common SSH key patterns, OR
          // 3. It contains SSH key content
          if (publicKeys.contains(fileName) ||
              fileName.startsWith('id_') ||
              fileName.contains('rsa') ||
              fileName.contains('dsa') ||
              fileName.contains('ecdsa') ||
              fileName.contains('ed25519') ||
              await _isLikelySSHKey(file.path)) {
            keyFiles.add(file.path);
          }
        }
      }

      return keyFiles;
    } catch (e) {
      _logger.error('Error getting available SSH keys: $e');
      return [];
    }
  }

  /// Check if a file is likely an SSH private key by examining its content
  Future<bool> _isLikelySSHKey(String filePath) async {
    try {
      final file = File(filePath);
      final stat = await file.stat();
      
      // Skip very large files (SSH keys are typically small)
      if (stat.size > 10000) {
        return false;
      }

      final content = await file.readAsString();
      
      // Check for SSH private key headers
      return content.contains('-----BEGIN') &&
             (content.contains('PRIVATE KEY') ||
              content.contains('RSA PRIVATE KEY') ||
              content.contains('DSA PRIVATE KEY') ||
              content.contains('EC PRIVATE KEY') ||
              content.contains('OPENSSH PRIVATE KEY'));
    } catch (e) {
      // If we can't read the file, assume it's not an SSH key
      return false;
    }
  }
}
