import React from 'react';
import {
  ShoppingCart,
  ShoppingBasket,
  Apple,
  Utensils,
  Coffee,
  Dumbbell,
  Plus,
  Minus,
  ChevronDown,
  Pencil,
  X,
  Trash2,
  MoreHorizontal,
  RefreshCw,
  Bell,
  Check,
  TrendingUp,
  TrendingDown,
} from 'lucide-react-native';

const iconMap: Record<string, any> = {
  ShoppingCart,
  ShoppingBasket,
  Apple,
  Utensils,
  Coffee,
  Dumbbell,
  Plus,
  Minus,
  ChevronDown,
  Pencil,
  X,
  Trash2,
  MoreHorizontal,
  RefreshCw,
  Bell,
  Check,
  TrendingUp,
  TrendingDown,
};

interface IconProps {
  name: string;
  size?: number;
  color?: string;
}

export default function Icon({ name, size = 20, color = '#000' }: IconProps) {
  const IconComponent = iconMap[name];
  if (!IconComponent) return null;
  return <IconComponent size={size} color={color} />;
}
