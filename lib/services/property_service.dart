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
      fetchPolicy: FetchPolicy.networkOnly, // Always get fresh data from server
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

  Future<List<Property>> getMyProperties() async {
    const String getMyPropertiesQuery = r'''
      query GetMyProperties {
        myProperties {
          idProperty
          idUser
          title
          city
          country
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
      document: gql(getMyPropertiesQuery),
      fetchPolicy: FetchPolicy.networkOnly, // Siempre obtener los datos más recientes
    );
    final QueryResult result = await client.query(options);
    if (result.hasException) {
      throw Exception(result.exception.toString());
    }
    final List<dynamic> propertiesJson = result.data!['myProperties'];
    return propertiesJson.map((json) => Property.fromJson(json)).toList();
  }

  Future<bool> deleteProperty(String propertyId) async {
    const String deletePropertyMutation = r'''
      mutation DeleteProperty($id: UUID!) {
        deleteProperty(id: $id)
      }
    ''';
    final MutationOptions options = MutationOptions(
      document: gql(deletePropertyMutation),
      variables: {'id': propertyId},
    );
    final QueryResult result = await client.mutate(options);
    if (result.hasException) {
      throw Exception(result.exception.toString());
    }
    return result.data?['deleteProperty'] ?? false;
  }

  Future<bool> updateProperty(String id, CreatePropertyInput input) async {
    const String mutation = r'''
      mutation UpdateProperty($id: UUID!, $input: UpdatePropertyInput!) {
        updateProperty(id: $id, input: $input)
      }
    ''';
    final options = MutationOptions(
      document: gql(mutation),
      variables: {
        'id': id,
        'input': input.toUpdateJson(),
      },
    );
    final result = await client.mutate(options);
    if (result.hasException) throw Exception(result.exception.toString());
    return result.data?['updateProperty'] ?? false;
  }
} 