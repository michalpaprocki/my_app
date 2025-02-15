// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

let Hooks = {}
Hooks.HandleCopy = {
  mounted() {
    const pre = document.querySelectorAll("pre")
    pre.forEach(p => {
      createAndAddCopyButton(p)
    })
  }
}
let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  hooks: Hooks,
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken}
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket


const createAndAddCopyButton = (element) => {
  const article = document.querySelector("article")
  const button = document.createElement("button")
  const div = document.createElement("div")
  const code = element.querySelector("code")
  
  div.classList.add("relative")
  button.classList.add("right-2")
  button.classList.add("right-2")
  button.classList.add("text-white")
  button.classList.add("top-2")
  button.classList.add("h-8")
  button.classList.add("w-16")
  button.classList.add("rounded-md")
  button.classList.add("font-semibold")
  button.classList.add("bg-violet-700")
  button.classList.add("transition")
  button.classList.add("hover:bg-violet-500")
  button.classList.add("absolute")
  button.title = "Copy bellow code"
  button.innerHTML = "Copy"
  div.append(button)
  article.insertBefore(div, element)
  element.remove()
  div.append(element)
  button.addEventListener("click", (event) => copyFunction(event, code))

}

const copyFunction = (event, code) => {
  if("clipboard" in navigator){
      const withGt = code.innerHTML.replaceAll("&gt;", ">")
      const withLt = withGt.replaceAll("&lt;", "<")
      const withAmp = withLt.replaceAll("&amp", "&")
      navigator.clipboard.writeText(withAmp)
      notifyAndCleanUp(event)
  } else {
      alert("Sorry, your browser does not support clipboard copy")
  }
}

const notifyAndCleanUp = (event) => {
  setTimeout(()=>{
    event.target.classList.remove("scale-110")
    event.target.innerHTML = "Copy"
  }, 1000)
  event.target.classList.add("scale-110")
  event.target.innerHTML = "Copied!"
}