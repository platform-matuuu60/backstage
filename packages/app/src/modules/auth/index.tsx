import { OAuth2 } from '@backstage/core-app-api';
import {
  IdentityProviders,
  SignInPage,
  SignInProviderConfig,
} from '@backstage/core-components';
import {
  BackstageIdentityApi,
  OpenIdConnectApi,
  ProfileInfoApi,
  SessionApi,
} from '@backstage/core-plugin-api';
import {
  ApiBlueprint,
  configApiRef,
  createApiRef,
  createFrontendModule,
  discoveryApiRef,
  oauthRequestApiRef,
} from '@backstage/frontend-plugin-api';
import { SignInPageBlueprint } from '@backstage/plugin-app-react';

/** Keycloak sign-in through Backstage's generic OIDC provider. */
export const keycloakAuthApiRef = createApiRef<
  OpenIdConnectApi & ProfileInfoApi & BackstageIdentityApi & SessionApi
>().with({ id: 'auth.keycloak' });

const keycloakAuthApi = ApiBlueprint.make({
  name: 'keycloak',
  params: defineParams =>
    defineParams({
      api: keycloakAuthApiRef,
      deps: {
        discoveryApi: discoveryApiRef,
        oauthRequestApi: oauthRequestApiRef,
        configApi: configApiRef,
      },
      factory: ({ discoveryApi, oauthRequestApi, configApi }) =>
        OAuth2.create({
          configApi,
          discoveryApi,
          oauthRequestApi,
          environment: configApi.getOptionalString('auth.environment'),
          // Must stay 'oidc' to match the backend OIDC provider.
          provider: { id: 'oidc', title: 'Keycloak', icon: () => null },
          defaultScopes: ['openid', 'profile', 'email'],
        }),
    }),
});

const signInPage = SignInPageBlueprint.make({
  params: {
    loader: async () => props => {
      const keycloak: SignInProviderConfig = {
        id: 'keycloak-auth-provider',
        title: 'Keycloak',
        message: 'Sign in with your platform account',
        apiRef: keycloakAuthApiRef,
      };
      // Guest sign-in is only offered in local development.
      const providers: IdentityProviders =
        process.env.NODE_ENV === 'development'
          ? ['guest', keycloak]
          : [keycloak];
      return <SignInPage {...props} providers={providers} />;
    },
  },
});

export const authModule = createFrontendModule({
  pluginId: 'app',
  extensions: [keycloakAuthApi, signInPage],
});
