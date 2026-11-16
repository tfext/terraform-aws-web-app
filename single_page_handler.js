// Uncomment export for testing.
/* export */ function handler(event) {
    const request = event.request;

    const parts = request.uri.split('/');
    const lastPartParts = parts[parts.length - 1].split('.');

    if (
        lastPartParts.length === 1 ||
        lastPartParts[lastPartParts.length - 1] === 'html'
    ) {
        request.uri = '/index.html';
    }

    return request
}
