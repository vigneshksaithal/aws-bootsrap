import { } from "bun"

const message = "Hello World\n"
const port = 8080

const server = Bun.serve({
    port: 8080,
    routes: {
        "/": () => new Response(message),
    },
})

console.log(`Listening on ${server.url}:${server.port}`)
