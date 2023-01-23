# NodeJS ServiceHub Framework

This NPM package provides a way to communicate with Visual Studio's `IRemoteServiceBroker` so that services proffered from Visual Studio can be consumed in a Node environment (e.g. Visual Studio Code).

## Usage

Given an instance of `IServiceBroker`, you can request a service (such as a simple calculator service) like this:

```ts
const proxy = await serviceBroker.getProxy<ICalculatorService>(CalculatorDescriptor);
try {
    if (proxy) {
        const sum = await proxy.add(3, 5);
        assert(sum == 8);
    }
} finally {
    proxy?.dispose();
}
```

Important points to remember:

1. Always be defensive by checking for an `null` result from the call for a service.
1. Always dispose the proxy when you're done with it to avoid leaking resources. These proxies do *not* get garbage collected automatically on account of the I/O resource they require.

Let's do something real. Visual Studio 16.6 includes a `VersionInfoService` that exposes the VS and Live Share versions on the host.
You can call that service from VS Code like this:

```ts
import * as isb from '@microsoft/servicehub-framework';
import * as vsls from 'vsls';

const VersionInfoService = new isb.ServiceJsonRpcDescriptor(
    isb.ServiceMoniker.create('Microsoft.VisualStudio.Shell.VersionInfoService', '1.0'),
    isb.Formatters.Utf8,
    isb.MessageDelimiters.HttpLikeHeaders);

interface IVersionInfoService {
    GetVersionInformationAsync(cancellationToken?: vscode.CancellationToken): Promise<VersionInformation>;
}

interface VersionInformation {
    visualStudioVersion: string;
    liveShareVersion: string;
}

const ls = await vsls.getApi();
const serviceBroker = await ls.services.getRemoteServiceBroker();
const proxy = await serviceBroker?.getProxy<IVersionInfoService>(VersionInfoService);
try {
    if (proxy) {
        const versionInfo = await proxy.GetVersionInformationAsync();
        console.log(`VS version: ${versionInfo.visualStudioVersion}`);
    }
} finally {
    proxy?.dispose();
}
```