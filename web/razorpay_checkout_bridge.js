(function () {
  function toMessage(error) {
    if (!error) {
      return 'Payment failed.';
    }

    if (typeof error === 'string') {
      return error;
    }

    return error.description || error.reason || error.message || 'Payment failed.';
  }

  window.jpumunRazorpay = {
    isReady: function () {
      return typeof window.Razorpay !== 'undefined';
    },
    openCheckout: function (optionsJson, onSuccess, onFailure, onDismiss) {
      if (typeof window.Razorpay === 'undefined') {
        onFailure(
          JSON.stringify({
            code: 'checkout_unavailable',
            description: 'Razorpay checkout script is not loaded.',
          }),
        );
        return;
      }

      var parsedOptions = JSON.parse(optionsJson);
      var existingModal = parsedOptions.modal || {};

      parsedOptions.handler = function (response) {
        onSuccess(JSON.stringify(response));
      };

      parsedOptions.modal = Object.assign({}, existingModal, {
        ondismiss: function () {
          if (typeof existingModal.ondismiss === 'function') {
            existingModal.ondismiss();
          }
          onDismiss();
        },
      });

      var razorpay = new window.Razorpay(parsedOptions);

      razorpay.on('payment.failed', function (response) {
        onFailure(
          JSON.stringify(response && response.error ? response.error : response),
        );
      });

      try {
        razorpay.open();
      } catch (error) {
        onFailure(
          JSON.stringify({
            code: 'checkout_open_failed',
            description: toMessage(error),
          }),
        );
      }
    },
  };
})();
