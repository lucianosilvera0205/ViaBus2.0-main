<!-- Seccion fija de metodos de pago en el inicio/home -->
 <template>
  <!-- descripcion de los pagos -->
  <div class="metodos-pago-container">
     <h2 class ="metodos-titulo">
        <q-icon name="credit card" size="24px" color="amber" />
        Métodos de Pago </h2>

    <p class="metodos-desc">
        Podés abonar tu pasaje con cualquiera de estas opciones, tanto al comprar en la web como en la terminal.
    </p>

     <!-- muestra los tipos de pagos aceptados-->
    <div class="metodos">
         <span class="metodo">
            <q-icon name="payments" size="24px" color="amber" />
            Efectivo
         </span>

         <span class="metodo">
            <q-icon name="account_balance_wallet" size="24px" color="amber" />
            Mercado Pago
         </span>

         <span class="metodo">
            <q-icon name="money" size="24px" color="amber" />
            Tarjeta de Credito
         </span>

         <span class="metodo">
            <q-icon name="account_balance" size="24px" color="amber" />
            Transferencia Bancaria
         </span>


       </div>
     </div>

   </template>

   <style scoped>
    .metodos-pago-container {
        max-width: 700px;
        margin: 40px auto 0;
        padding: 30px 40px;
        text-align: center;
        background-color: #0f1629;
        border-radius: 8px;
        border: 1px solid #1a2138;
    }

    .metodos-titulo {
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 10px;
        color: #f4b400;
        font-size: 22px;
        margin-bottom: 10px;
    }

    .metodos-desc {
        color: #9aa4bf;
        margin-bottom: 20px;
    }

    .metodos {
        display: flex;
        justify-content: center;
        gap: 16px;
        flex-wrap: wrap;
    }

    .metodo {
        display: flex;
        align-items: center;
        gap: 8px;
        background-color: #151d33;
        font-size: 1.2em;
        border-radius: 8px;
        border: 1px solid #1a2138;
        padding: 10px 15px;
        transition: background-color 0.3s, color 0.3s;
        color: #e8ecf5;


    }

    </style>
