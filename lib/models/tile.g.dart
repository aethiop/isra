// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Tile _$TileFromJson(Map json) => Tile(
      json['id'] as String,
      (json['value'] as num).toInt(),
      (json['index'] as num).toInt(),
      nextIndex: (json['nextIndex'] as num?)?.toInt(),
      merged: json['merged'] as bool? ?? false,
    );

Map<String, dynamic> _$TileToJson(Tile instance) => <String, dynamic>{
      'id': instance.id,
      'value': instance.value,
      'index': instance.index,
      'nextIndex': instance.nextIndex,
      'merged': instance.merged,
    };
