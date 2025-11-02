import React from 'react';
import './EnvelopeAnimation.css';

const EnvelopeAnimation = ({ onAnimationComplete }) => {
  const [animationStarted, setAnimationStarted] = React.useState(false);
  const [hideEnvelope, setHideEnvelope] = React.useState(false);
  const [envelopeTransform, setEnvelopeTransform] = React.useState('');
  const [showConfetti, setShowConfetti] = React.useState(false);
  const [letterPulledOut, setLetterPulledOut] = React.useState(false);

  const handleClick = () => {
    if (animationStarted) return;
    setAnimationStarted(true);

    // Запускаем салют при открытии
    setTimeout(() => {
      setShowConfetti(true);
    }, 500);

    // Конверт опускается вниз через 800ms
    setTimeout(() => {
      setEnvelopeTransform('translateY(300px)');
    }, 800);

    setTimeout(() => {
      setLetterPulledOut(true);
    }, 1000);

    // Скрываем конверт и показываем основной контент через 4 секунды
    setTimeout(() => {
      setHideEnvelope(true);
      onAnimationComplete();
    }, 4000);
  };

  // Создаем массив для конфетти
  const confettiPieces = Array.from({ length: 50 }, (_, i) => ({
    id: i,
    left: Math.random() * 100,
    delay: Math.random() * 1,
    duration: 4 + Math.random() * 2,
    rotation: Math.random() * 360
  }));

  return (
    <div className={`envelope-wrapper ${hideEnvelope ? 'hidden' : ''}`} id="envelope-wrapper">
      {/* Плавающие частицы */}
      <div className="floating-particles">
        <div className="particle"></div>
        <div className="particle"></div>
        <div className="particle"></div>
        <div className="particle"></div>
        <div className="particle"></div>
      </div>

      <div 
        className="envelope-container" 
        id="envelope"
        onClick={handleClick}
        style={{
          transform: envelopeTransform,
          transition: envelopeTransform ? 'transform 1.2s cubic-bezier(0.68, -0.55, 0.265, 1.55)' : 'none'
        }}
      >
        <div className="envelope-back"></div>
        <div
          className={`letter ${animationStarted ? 'pull-out' : ''}`}
          id="letter"
          style={{
            zIndex: letterPulledOut ? '5' : '0'
          }}
        >
          <h1 className="letter-text">Дмитрий</h1>
          <div className="ampersand">&</div>
          <h1 className="letter-text">Екатерина</h1>
          <div className="divider"></div>
          <p className="letter-subtext">Приглашают вас</p>
        </div>
        <div className={`envelope-flap ${animationStarted ? 'open' : ''}`} id="flap"></div>
        <div className={`seal ${animationStarted ? 'fade-out' : ''}`} id="seal">
          <div className="seal-inner">D&E</div>
        </div>
        <div className="click-hint">Нажмите, чтобы открыть</div>
      </div>

      {/* Салют/Конфетти */}
      {showConfetti && (
        <div className="confetti-container">
          {confettiPieces.map((piece) => (
            <div
              key={piece.id}
              className="confetti"
              style={{
                left: `${piece.left}%`,
                animationDelay: `${piece.delay}s`,
                animationDuration: `${piece.duration}s`,
                transform: `rotate(${piece.rotation}deg)`
              }}
            />
          ))}
        </div>
      )}
    </div>
  );
};

export default EnvelopeAnimation;

