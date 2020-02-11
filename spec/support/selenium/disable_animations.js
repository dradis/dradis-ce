var disableAnimationStyles = 'transition-property: none !important;' +
                             '-webkit-transition-property: none !important;' +
                             '-webkit-transition: none !important;' +
                             '-moz-transition: none !important;' +
                             '-ms-transition: none !important;' +
                             '-o-transition: none !important;' +
                             'transition: none !important;'

var animationStyles = document.createElement('style');
animationStyles.type = 'text/css';
animationStyles.innerHTML = '* {' + disableAnimationStyles + '}';
document.head.appendChild(animationStyles);
