const swaggerJsdoc = require('swagger-jsdoc');

const options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'SafeHer-AI API',
      version: '1.0.0',
      description: 'REST API documentation for the SafeHer-AI backend.',
    },
    servers: [
      {
        url: '{baseUrl}',
        description: 'Dynamic server',
        variables: {
          baseUrl: {
            default: 'http://localhost:3000',
            description: 'The base URL for API endpoints. In production, this will be your deployed URL (e.g. https://abhaya-2.onrender.com).',
          }
        }
      },
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
        },
      },
    },
    security: [
      {
        bearerAuth: [],
      },
    ],
  },
  apis: ['./src/routes/*.js', './src/models/*.js'],
};

const swaggerSpec = swaggerJsdoc(options);

module.exports = swaggerSpec;
