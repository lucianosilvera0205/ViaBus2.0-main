// IMPORTAMOS VUE
import { createApp } from 'vue'

// IMPORTAMOS HELMET
import helmet from "helmet"

// IMPORTAMOS APP
import App from './App.vue'

// IMPORTAMOS ROUTER
import router from './router'

// IMPORTAMOS QUASAR
import { Quasar } from 'quasar'

// IMPORTAMOS CSS DE QUASAR
import 'quasar/src/css/index.sass'

// ICONOS
import '@quasar/extras/material-icons/material-icons.css'

// ESTILOS GLOBALES
import './assets/styles/global.css'

createApp(App)
  .use(router)
  .use(Quasar, {
    plugins: {}
  })
  .mount('#app')

 const app = express();

 app.use(helmet());


