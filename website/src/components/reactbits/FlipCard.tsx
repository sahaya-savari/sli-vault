"use client";

import React, { useEffect, useRef, useState } from "react";
import {
  animate,
  motion,
  useMotionTemplate,
  useMotionValue,
  useReducedMotion,
  useSpring,
  useTransform,
} from "motion/react";

import "./FlipCard.css";

export interface FlipCardProps {
  /** Content rendered on the front face of the card */
  front?: React.ReactNode;
  /** Content rendered on the back face of the card */
  back?: React.ReactNode;
  /** Controlled flipped state. When provided, component behaves as controlled */
  flipped?: boolean;
  /** Uncontrolled initial flipped state */
  defaultFlipped?: boolean;
  /** Callback fired whenever the card flips to a different face */
  onFlipChange?: (isBackFace: boolean) => void;
  /** Axis of rotation: "y" flips horizontally, "x" flips vertically */
  axis?: "x" | "y";
  /** Flip card on click or tap */
  flipOnClick?: boolean;
  /** Enable dragging gestures to rotate the card */
  draggable?: boolean;
  /** Required drag distance in pixels for a 180deg flip (0 uses card width/height) */
  dragDistance?: number;
  /** Enable 3D tilt leaning toward cursor */
  tilt?: boolean;
  /** Maximum tilt angle in degrees */
  tiltMax?: number;
  /** Enable cursor-following glare sheen */
  glare?: boolean;
  /** Maximum opacity of the sheen */
  glareOpacity?: number;
  /** Scale lift factor on hover or press */
  hoverScale?: number;
  /** 3D CSS perspective in pixels */
  perspective?: number;
  /** Spring stiffness for flip rotation */
  stiffness?: number;
  /** Spring damping for flip rotation */
  damping?: number;
  /** Card width (number in px or CSS string) */
  width?: number | string;
  /** Card height (number in px or CSS string) */
  height?: number | string;
  /** Corner border radius in pixels */
  radius?: number;
  /** Face background color */
  background?: string;
  /** Face text color */
  color?: string;
  /** Enable dynamic ground shadow */
  shadow?: boolean;
  /** Ground shadow color */
  shadowColor?: string;
  /** Ground shadow opacity */
  shadowOpacity?: number;
  /** Disables interactions and dims visual style */
  disabled?: boolean;
  /** Accessible label */
  ariaLabel?: string;
  /** Additional CSS class name */
  className?: string;
  /** Inline style overrides */
  style?: React.CSSProperties;
}

interface DragHistoryPoint {
  timestamp: number;
  rotationDegrees: number;
}

interface PointerGripSession {
  pointerId: number;
  startX: number;
  startY: number;
  baseRotationDegrees: number;
  hasExceededThreshold: boolean;
  slopThresholdPixels: number;
  movementHistory: DragHistoryPoint[];
}

const DRAG_SLOP_PIXELS = {
  finePointer: 4,
  touchPointer: 8,
} as const;

const TILT_SPRING_CONFIG = {
  stiffness: 240,
  damping: 24,
  mass: 0.6,
} as const;

const LIFT_SPRING_CONFIG = {
  stiffness: 320,
  damping: 26,
} as const;

const FLING_INERTIA_COEFFICIENT = 0.16;
const VELOCITY_HISTORY_WINDOW_MS = 90;

function clampNumber(value: number, min: number, max: number): number {
  return Math.min(max, Math.max(min, value));
}

function snapToNearest180Degrees(degrees: number): number {
  return Math.round(degrees / 180) * 180;
}

function isBackFaceShowing(degrees: number): boolean {
  return Math.abs(Math.round(degrees / 180)) % 2 === 1;
}

function calculateFlingVelocity(history: DragHistoryPoint[], currentTime: number): number {
  if (history.length < 2) return 0;
  const initialPoint = history[0];
  const latestPoint = history[history.length - 1];
  const timeDifferenceMs = latestPoint.timestamp - initialPoint.timestamp;
  const isRecentMovement = currentTime - latestPoint.timestamp < 60;

  if (timeDifferenceMs > 0 && isRecentMovement) {
    const rotationDelta = latestPoint.rotationDegrees - initialPoint.rotationDegrees;
    return (rotationDelta / timeDifferenceMs) * 1000;
  }
  return 0;
}

function calculateTargetRotationOnRelease(options: {
  isCancelled: boolean;
  baseRotation: number;
  currentRotation: number;
  flingVelocity: number;
}): number {
  const { isCancelled, baseRotation, currentRotation, flingVelocity } = options;

  if (isCancelled) {
    return snapToNearest180Degrees(baseRotation);
  }

  const projectedRotation = currentRotation + flingVelocity * FLING_INERTIA_COEFFICIENT;
  const nearestSnap = snapToNearest180Degrees(currentRotation);

  return clampNumber(
    snapToNearest180Degrees(projectedRotation),
    nearestSnap - 180,
    nearestSnap + 180,
  );
}

export const FlipCard: React.FC<FlipCardProps> = ({
  front = null,
  back = null,
  flipped,
  defaultFlipped = false,
  onFlipChange,
  axis = "y",
  flipOnClick = true,
  draggable = true,
  dragDistance = 0,
  tilt = true,
  tiltMax = 12,
  glare = true,
  glareOpacity = 0.22,
  hoverScale = 1.03,
  perspective = 1100,
  stiffness = 170,
  damping = 20,
  width = "100%",
  height = 280,
  radius = 18,
  background = "#111114",
  color = "#fafafa",
  shadow = true,
  shadowColor = "#000000",
  shadowOpacity = 0.45,
  disabled = false,
  ariaLabel = "Flip card",
  className = "",
  style,
}) => {
  const prefersReducedMotion = useReducedMotion();
  const isControlled = flipped !== undefined;
  const [internalFlippedState, setInternalFlippedState] = useState(defaultFlipped);
  const [isDragging, setIsDragging] = useState(false);

  const activeFaceIsBack = isControlled ? flipped : internalFlippedState;
  const activeFaceRef = useRef(activeFaceIsBack);
  activeFaceRef.current = activeFaceIsBack;

  const rootElementRef = useRef<HTMLDivElement | null>(null);
  const activeGripSessionRef = useRef<PointerGripSession | null>(null);
  const activeSpinAnimationRef = useRef<{ stop: () => void } | null>(null);
  const targetRotationDegreesRef = useRef(activeFaceIsBack ? 180 : 0);

  // Motion values
  const rotationDegrees = useMotionValue(activeFaceIsBack ? 180 : 0);
  const tiltAngleX = useSpring(0, TILT_SPRING_CONFIG);
  const tiltAngleY = useSpring(0, TILT_SPRING_CONFIG);
  const liftScale = useSpring(1, LIFT_SPRING_CONFIG);
  const sheenIntensity = useSpring(0, LIFT_SPRING_CONFIG);
  const glareCenterX = useMotionValue(50);
  const glareCenterY = useMotionValue(50);

  // Derived 3D transform calculations
  const combinedRotationX = useTransform(
    [rotationDegrees, tiltAngleX],
    ([rot, tilt]) => (Number(rot) || 0) + (Number(tilt) || 0),
  );
  const combinedRotationY = useTransform(
    [rotationDegrees, tiltAngleY],
    ([rot, tilt]) => (Number(rot) || 0) + (Number(tilt) || 0),
  );

  const transformTemplateY = useMotionTemplate`perspective(${perspective}px) scale(${liftScale}) rotateX(${tiltAngleX}deg) rotateY(${combinedRotationY}deg)`;
  const transformTemplateX = useMotionTemplate`perspective(${perspective}px) scale(${liftScale}) rotateY(${tiltAngleY}deg) rotateX(${combinedRotationX}deg)`;

  const cardFacingRatio = useTransform(rotationDegrees, (deg) =>
    Math.abs(Math.cos((Number(deg) * Math.PI) / 180)),
  );
  const shadowSpreadScale = useTransform(cardFacingRatio, (ratio) => 0.08 + 0.92 * ratio);
  const shadowOpacityScale = useTransform(cardFacingRatio, (ratio) => 0.1 + 0.9 * ratio * ratio);

  const glareCenterXPct = useMotionTemplate`${glareCenterX}%`;
  const glareCenterYPct = useMotionTemplate`${glareCenterY}%`;

  const settleRotation = (
    destinationDegrees: number,
    initialVelocity: number,
    instantJump: boolean,
  ) => {
    activeSpinAnimationRef.current?.stop();
    targetRotationDegreesRef.current = destinationDegrees;

    if (instantJump || prefersReducedMotion) {
      rotationDegrees.jump(destinationDegrees);
    } else {
      activeSpinAnimationRef.current = animate(rotationDegrees, destinationDegrees, {
        type: "spring",
        stiffness,
        damping,
        velocity: initialVelocity,
        restDelta: 0.05,
      });
    }

    const nextIsBack = isBackFaceShowing(destinationDegrees);
    if (nextIsBack === activeFaceRef.current) return;

    activeFaceRef.current = nextIsBack;
    if (!isControlled) {
      setInternalFlippedState(nextIsBack);
    }
    onFlipChange?.(nextIsBack);
  };

  const executeCardFlip = (instantJump: boolean) => {
    const currentSnappedBase = snapToNearest180Degrees(rotationDegrees.get());
    const targetFaceRotation = isBackFaceShowing(currentSnappedBase)
      ? currentSnappedBase - 180
      : currentSnappedBase + 180;
    settleRotation(targetFaceRotation, 0, instantJump);
  };

  const resetTiltAndSheen = () => {
    tiltAngleX.set(0);
    tiltAngleY.set(0);
    sheenIntensity.set(0);
    liftScale.set(1);
  };

  // Synchronize controlled flipped prop
  useEffect(() => {
    if (!isControlled || isBackFaceShowing(targetRotationDegreesRef.current) === flipped) {
      return;
    }
    const currentBase = targetRotationDegreesRef.current;
    activeSpinAnimationRef.current?.stop();
    const updatedTarget = isBackFaceShowing(currentBase) ? currentBase - 180 : currentBase + 180;
    targetRotationDegreesRef.current = updatedTarget;

    if (prefersReducedMotion) {
      rotationDegrees.jump(updatedTarget);
    } else {
      activeSpinAnimationRef.current = animate(rotationDegrees, updatedTarget, {
        type: "spring",
        stiffness,
        damping,
        restDelta: 0.05,
      });
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [flipped]);

  useEffect(() => () => activeSpinAnimationRef.current?.stop(), []);

  useEffect(() => {
    if (disabled) resetTiltAndSheen();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [disabled]);

  const handlePointerDown = (event: React.PointerEvent<HTMLDivElement>) => {
    if (disabled || event.button !== 0 || activeGripSessionRef.current) return;

    try {
      event.currentTarget.setPointerCapture(event.pointerId);
    } catch {
      // Ignore if pointer capture is not supported
    }

    activeSpinAnimationRef.current?.stop();
    activeGripSessionRef.current = {
      pointerId: event.pointerId,
      startX: event.clientX,
      startY: event.clientY,
      baseRotationDegrees: rotationDegrees.get(),
      hasExceededThreshold: false,
      slopThresholdPixels:
        event.pointerType === "touch"
          ? DRAG_SLOP_PIXELS.touchPointer
          : DRAG_SLOP_PIXELS.finePointer,
      movementHistory: [],
    };

    if (!prefersReducedMotion) {
      liftScale.set(hoverScale);
    }
  };

  const handlePointerMove = (event: React.PointerEvent<HTMLDivElement>) => {
    const session = activeGripSessionRef.current;

    // Active drag handling
    if (session && session.pointerId === event.pointerId) {
      const deltaDistance =
        axis === "x" ? event.clientY - session.startY : event.clientX - session.startX;

      if (!session.hasExceededThreshold) {
        if (
          Math.abs(deltaDistance) < session.slopThresholdPixels ||
          !draggable ||
          prefersReducedMotion
        ) {
          return;
        }
        session.hasExceededThreshold = true;
        setIsDragging(true);
        tiltAngleX.set(0);
        tiltAngleY.set(0);
        sheenIntensity.set(0);
      }

      const boundingRectangle = event.currentTarget.getBoundingClientRect();
      const dragSpanPixels =
        dragDistance > 0
          ? dragDistance
          : axis === "x"
            ? boundingRectangle.height
            : boundingRectangle.width;

      const deltaNormalized = deltaDistance / Math.max(1, dragSpanPixels);
      const axisDirection = axis === "x" ? -1 : 1;
      const calculatedDegrees = session.baseRotationDegrees + axisDirection * deltaNormalized * 180;

      rotationDegrees.set(calculatedDegrees);

      const currentTime = performance.now();
      session.movementHistory.push({
        timestamp: currentTime,
        rotationDegrees: calculatedDegrees,
      });

      while (
        session.movementHistory.length > 2 &&
        currentTime - session.movementHistory[0].timestamp > VELOCITY_HISTORY_WINDOW_MS
      ) {
        session.movementHistory.shift();
      }
      return;
    }

    // Passive hover tilt and glare handling
    if (!tilt || prefersReducedMotion || disabled || event.pointerType === "touch") {
      return;
    }

    const rect = event.currentTarget.getBoundingClientRect();
    const normalizedPointerX = clampNumber((event.clientX - rect.left) / rect.width, 0, 1);
    const normalizedPointerY = clampNumber((event.clientY - rect.top) / rect.height, 0, 1);

    tiltAngleX.set((0.5 - normalizedPointerY) * 2 * tiltMax);
    tiltAngleY.set((normalizedPointerX - 0.5) * 2 * tiltMax);
    glareCenterX.set(normalizedPointerX * 100);
    glareCenterY.set(normalizedPointerY * 100);
    sheenIntensity.set(1);
  };

  const handlePointerRelease = (
    event: React.PointerEvent<HTMLDivElement>,
    wasCancelled: boolean,
  ) => {
    const session = activeGripSessionRef.current;
    if (!session || session.pointerId !== event.pointerId) return;

    activeGripSessionRef.current = null;
    try {
      if (event.currentTarget.hasPointerCapture(event.pointerId)) {
        event.currentTarget.releasePointerCapture(event.pointerId);
      }
    } catch {
      // Ignore if pointer capture already released
    }

    setIsDragging(false);

    const isHovering = rootElementRef.current?.matches(":hover");
    if (event.pointerType === "touch" || !isHovering) {
      resetTiltAndSheen();
    }

    if (!session.hasExceededThreshold) {
      if (!wasCancelled && flipOnClick) {
        executeCardFlip(false);
      } else {
        settleRotation(targetRotationDegreesRef.current, 0, false);
      }
      return;
    }

    const currentDeg = rotationDegrees.get();
    const flingVelocity = wasCancelled
      ? 0
      : calculateFlingVelocity(session.movementHistory, performance.now());

    const destinationDegrees = calculateTargetRotationOnRelease({
      isCancelled: wasCancelled,
      baseRotation: session.baseRotationDegrees,
      currentRotation: currentDeg,
      flingVelocity,
    });

    settleRotation(destinationDegrees, flingVelocity, false);
  };

  const handleKeyDown = (event: React.KeyboardEvent<HTMLDivElement>) => {
    if (disabled || (event.key !== "Enter" && event.key !== " ")) return;
    event.preventDefault();
    if (!event.repeat) {
      executeCardFlip(true);
    }
  };

  const handleClick = (event: React.MouseEvent<HTMLDivElement>) => {
    // Keyboard simulated click has detail === 0
    if (!disabled && event.detail === 0) {
      executeCardFlip(true);
    }
  };

  const dynamicRotorStyle = {
    transform: axis === "x" ? transformTemplateX : transformTemplateY,
    "--fc-gx": glareCenterXPct,
    "--fc-gy": glareCenterYPct,
    "--fc-sheen": sheenIntensity,
  };

  const widthStyleValue = typeof width === "number" ? `${width}px` : width;
  const heightStyleValue = typeof height === "number" ? `${height}px` : height;

  return (
    <div
      ref={rootElementRef}
      role="button"
      tabIndex={disabled ? -1 : 0}
      aria-pressed={activeFaceIsBack}
      aria-label={ariaLabel}
      aria-disabled={disabled || undefined}
      className={`flip-card${className ? ` ${className}` : ""}`}
      data-axis={axis}
      data-draggable={draggable && !disabled && !prefersReducedMotion ? "" : undefined}
      data-dragging={isDragging ? "" : undefined}
      data-disabled={disabled ? "" : undefined}
      data-fade={prefersReducedMotion ? (activeFaceIsBack ? "back" : "front") : undefined}
      onPointerDown={handlePointerDown}
      onPointerMove={handlePointerMove}
      onPointerUp={(event) => handlePointerRelease(event, false)}
      onPointerCancel={(event) => handlePointerRelease(event, true)}
      onLostPointerCapture={(event) => handlePointerRelease(event, true)}
      onPointerEnter={(event) => {
        if (!prefersReducedMotion && !disabled && event.pointerType !== "touch") {
          liftScale.set(hoverScale);
        }
      }}
      onPointerLeave={() => {
        if (!activeGripSessionRef.current) resetTiltAndSheen();
      }}
      onKeyDown={handleKeyDown}
      onClick={handleClick}
      onDragStart={(event) => event.preventDefault()}
      style={
        {
          "--fc-w": widthStyleValue,
          "--fc-h": heightStyleValue,
          "--fc-radius": `${radius}px`,
          "--fc-bg": background,
          "--fc-ink": color,
          "--fc-shadow": shadowColor,
          "--fc-shadow-o": shadowOpacity,
          "--fc-glare": glareOpacity,
          ...style,
        } as React.CSSProperties
      }
    >
      {shadow ? (
        <motion.span
          className="flip-card__shadow"
          aria-hidden="true"
          style={
            axis === "x"
              ? { scaleY: shadowSpreadScale, opacity: shadowOpacityScale }
              : { scaleX: shadowSpreadScale, opacity: shadowOpacityScale }
          }
        />
      ) : null}
      <motion.div
        className="flip-card__rotor"
        style={prefersReducedMotion ? undefined : dynamicRotorStyle}
      >
        <div
          className="flip-card__face flip-card__face--front"
          aria-hidden={activeFaceIsBack}
          inert={activeFaceIsBack}
        >
          {front}
          {glare ? <span className="flip-card__glare" aria-hidden="true" /> : null}
        </div>
        <div
          className="flip-card__face flip-card__face--back"
          aria-hidden={!activeFaceIsBack}
          inert={!activeFaceIsBack}
        >
          {back}
          {glare ? <span className="flip-card__glare" aria-hidden="true" /> : null}
        </div>
      </motion.div>
    </div>
  );
};

export default FlipCard;
