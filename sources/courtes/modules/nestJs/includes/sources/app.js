async function login() {
    const data = {
        email: 'admin@admin.com',
        password: 'secret',
    };

    const res = await fetch('http://localhost:3000/auth/login', {
        headers: {
            'content-type': 'application/json',
        },
        method: 'POST',
        body: JSON.stringify(data),
    });

    return await res.json();
}

async function getNotes(token) {
    const res = await fetch('http://localhost:3000/notes', {
        headers: {
            'content-type': 'application/json',
            authorization: `Bearer ${token}`,
        },
        method: 'GET',
    });

    return await res.json();
}

// IIFE => https://developer.mozilla.org/en-US/docs/Glossary/IIFE
(async () => {
    const res = await login();
    const data = await getNotes(res.user.access_token);
    console.log(data);
})();
