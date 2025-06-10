import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/create_property_input.dart';
import '../models/property.dart';

class PropertyService {
  final GraphQLClient client;

  PropertyService({required this.client});

  Future<List<Property>> getProperties() async {
    const String getPropertiesQuery = r'''
      query GetProperties {
        allProperties {
          idProperty
          idUser
          title
          description
          address
          city
          country
          propertyType
          transactionType
          status
          price
          area
          builtArea
          bedrooms
          photos
          createdAt
          updatedAt
        }
      }
    ''';

    final QueryOptions options = QueryOptions(
      document: gql(getPropertiesQuery),
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final List<dynamic> propertiesJson = result.data!['allProperties'];
    return propertiesJson.map((json) => Property.fromJson(json)).toList();
  }

  Future<Property> createProperty(CreatePropertyInput input) async {
    const String createPropertyMutation = r'''
      mutation CreateProperty($input: CreatePropertyRequestInput!) {
        createProperty(input: $input) {
          idProperty
          idUser
          title
          description
          address
          city
          country
          propertyType
          transactionType
          status
          price
          area
          builtArea
          bedrooms
          photos
          createdAt
          updatedAt
        }
      }
    ''';

    final MutationOptions options = MutationOptions(
      document: gql(createPropertyMutation),
      variables: {
        'input': input.toJson(),
      },
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final Map<String, dynamic> propertyJson = result.data!['createProperty'];
    return Property.fromJson(propertyJson);
  }
} 